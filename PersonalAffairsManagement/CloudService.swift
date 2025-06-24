//
//  CloudService.swift
//  PersonalAffairsManagement
//
//  Created by 汤寿麟 on 2025/6/23.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import FirebaseCore
import Combine

// 自定义错误类型
enum CloudServiceError: Error, LocalizedError {
    case firebaseNotConfigured
    
    var errorDescription: String? {
        switch self {
        case .firebaseNotConfigured:
            return "Firebase 未配置。请检查 GoogleService-Info.plist 文件。"
        }
    }
}

// MARK: - 云端服务管理
class CloudService: ObservableObject {
    static let shared = CloudService()
    
    // 延迟初始化 Firestore，只有在真正需要时才创建
    private lazy var db: Firestore = {
        // 检查 Firebase 是否已配置
        guard FirebaseApp.app() != nil else {
            fatalError("Firebase not configured. Please call FirebaseApp.configure() before using CloudService")
        }
        return Firestore.firestore()
    }()
    
    private var cancellables = Set<AnyCancellable>()
    
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var syncStatus: String?
    
    private var stateHandle: AuthStateDidChangeListenerHandle?
    
    private init() {
        // 暂时不设置认证监听器，等 Firebase 配置完成后再设置
        // setupAuthListener()
    }
    
    // MARK: - 初始化 Firebase 相关服务
    func initializeFirebaseServices() {
        guard FirebaseApp.app() != nil else {
            print("[CloudService] Firebase not configured, skipping service initialization.")
            return
        }
        setupAuthListener()
    }
    
    // MARK: - 认证管理
    func signIn(email: String, password: String) async throws {
        guard FirebaseApp.app() != nil else {
            print("[CloudService] Firebase not configured, cannot sign in.")
            throw CloudServiceError.firebaseNotConfigured
        }
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        await MainActor.run {
            self.currentUser = result.user
        }
    }
    
    func signUp(email: String, password: String) async throws {
        guard FirebaseApp.app() != nil else {
            print("[CloudService] Firebase not configured, cannot sign up.")
            throw CloudServiceError.firebaseNotConfigured
        }
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        await MainActor.run {
            self.currentUser = result.user
        }
    }
    
    func signOut() throws {
        guard FirebaseApp.app() != nil else {
            print("[CloudService] Firebase not configured, cannot sign out.")
            return
        }
        try Auth.auth().signOut()
        DispatchQueue.main.async {
            self.currentUser = nil
            self.isAuthenticated = false
        }
    }
    
    // MARK: - 设置观察者
    private func setupAuthListener() {
        guard FirebaseApp.app() != nil else {
            print("[CloudService] Firebase not configured, skipping auth listener.")
            return
        }
        
        // 移除旧的监听器以防重复
        if let handle = stateHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
        
        print("[CloudService] Setting up auth state listener.")
        stateHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task {
                await MainActor.run {
                    if let user = user {
                        print("[CloudService] Auth state changed: User is signed in with UID: \(user.uid)")
                        self?.currentUser = user
                        self?.isAuthenticated = true
                    } else {
                        print("[CloudService] Auth state changed: User is signed out.")
                        self?.currentUser = nil
                        self?.isAuthenticated = false
                    }
                }
            }
        }
    }
    
    // MARK: - 数据同步
    
    func syncData<T: Codable & CloudModel>(_ items: [T], collection: String) async throws {
        guard let userId = currentUser?.uid else {
            print("[CloudService] 同步失败：用户未登录")
            throw NSError(domain: "CloudService", code: -1, userInfo: [NSLocalizedDescriptionKey: "用户未登录"])
        }
        
        let collectionRef = db.collection("users").document(userId).collection(collection)
        
        await MainActor.run {
            self.syncStatus = "开始同步 \(collection)..."
        }
        
        print("[CloudService] 开始同步 \(collection)，共 \(items.count) 条数据")
        print("[CloudService] 用户ID: \(userId)")
        
        var successCount = 0
        var errorCount = 0
        
        for (index, item) in items.enumerated() {
            do {
                if let docId = item.id {
                    print("[CloudService] 同步 \(collection) 第 \(index + 1) 条数据，ID: \(docId)")
                    try await collectionRef.document(docId).setData(from: item)
                    successCount += 1
                } else {
                    print("[CloudService] 跳过 \(collection) 第 \(index + 1) 条数据：ID为空")
                    errorCount += 1
                }
            } catch {
                print("[CloudService] 同步 \(collection) 第 \(index + 1) 条数据失败: \(error)")
                await MainActor.run {
                    self.syncStatus = "同步 \(collection) 失败: \(error.localizedDescription)"
                }
                throw error
            }
        }
        
        print("[CloudService] \(collection) 同步完成：成功 \(successCount) 条，失败 \(errorCount) 条")
        
        await MainActor.run {
            self.syncStatus = "\(collection) 同步完成：成功 \(successCount) 条，失败 \(errorCount) 条。"
        }
    }
    
    func fetchData<T: Codable & CloudModel>(collection: String) async throws -> [T] {
        guard let userId = currentUser?.uid else { throw CloudError.notAuthenticated }
        
        let snapshot = try await db.collection("users").document(userId).collection(collection).getDocuments()
        
        return try snapshot.documents.compactMap { document in
            try document.data(as: T.self)
        }
    }
    
    func deleteData<T: CloudModel>(_ item: T, collection: String) async throws {
        guard let userId = currentUser?.uid, let docId = item.id else { throw CloudError.notAuthenticated }
        
        try await db.collection("users").document(userId).collection(collection).document(docId).delete()
    }
}

// MARK: - 云端模型协议
protocol CloudModel: Codable {
    var id: String? { get set }
}

// MARK: - 同步状态
enum SyncStatus {
    case idle
    case syncing
    case completed
    case failed(Error)
}

// MARK: - 云端错误
enum CloudError: Error, LocalizedError {
    case notAuthenticated
    case dataConversionFailed
    case networkError
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "用户未认证"
        case .dataConversionFailed:
            return "数据转换失败，请检查模型定义。"
        case .networkError:
            return "网络连接错误"
        case .unknown:
            return "未知错误"
        }
    }
} 