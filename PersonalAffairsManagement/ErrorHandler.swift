//
//  ErrorHandler.swift
//  PersonalAffairsManagement
//
//  Created by 汤寿麟 on 2025/6/23.
//

import Foundation
import SwiftUI

// MARK: - 应用错误类型
enum AppError: Error, LocalizedError, Identifiable {
    case networkError(String)
    case dataError(String)
    case authenticationError(String)
    case syncError(String)
    case validationError(String)
    case unknownError(String)
    
    var id: String {
        switch self {
        case .networkError(let message):
            return "network_\(message)"
        case .dataError(let message):
            return "data_\(message)"
        case .authenticationError(let message):
            return "auth_\(message)"
        case .syncError(let message):
            return "sync_\(message)"
        case .validationError(let message):
            return "validation_\(message)"
        case .unknownError(let message):
            return "unknown_\(message)"
        }
    }
    
    var errorDescription: String? {
        switch self {
        case .networkError(let message):
            return "网络错误: \(message)"
        case .dataError(let message):
            return "数据错误: \(message)"
        case .authenticationError(let message):
            return "认证错误: \(message)"
        case .syncError(let message):
            return "同步错误: \(message)"
        case .validationError(let message):
            return "验证错误: \(message)"
        case .unknownError(let message):
            return "未知错误: \(message)"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .networkError:
            return "请检查网络连接后重试"
        case .dataError:
            return "请重新加载数据"
        case .authenticationError:
            return "请重新登录"
        case .syncError:
            return "请稍后重试同步"
        case .validationError:
            return "请检查输入内容"
        case .unknownError:
            return "请重启应用后重试"
        }
    }
}

// MARK: - 错误处理器
@MainActor
class ErrorHandler: ObservableObject {
    @Published var currentError: AppError?
    @Published var showingError = false
    @Published var errorQueue: [AppError] = []
    
    static let shared = ErrorHandler()
    
    private init() {}
    
    func handle(_ error: Error) {
        let appError: AppError
        
        if let appErrorCast = error as? AppError {
            appError = appErrorCast
        } else if let cloudError = error as? CloudError {
            appError = .syncError(cloudError.localizedDescription)
        } else {
            appError = .unknownError(error.localizedDescription)
        }
        
        // 添加到队列
        errorQueue.append(appError)
        
        // 如果没有当前错误，显示新错误
        if currentError == nil {
            showNextError()
        }
    }
    
    func showNextError() {
        guard !errorQueue.isEmpty else {
            currentError = nil
            showingError = false
            return
        }
        
        currentError = errorQueue.removeFirst()
        showingError = true
    }
    
    func dismissError() {
        showingError = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.showNextError()
        }
    }
    
    func clearAllErrors() {
        errorQueue.removeAll()
        currentError = nil
        showingError = false
    }
}

// MARK: - 错误显示视图
struct ErrorAlert: View {
    @ObservedObject var errorHandler: ErrorHandler
    
    var body: some View {
        EmptyView()
            .alert("错误", isPresented: $errorHandler.showingError) {
                Button("确定") {
                    errorHandler.dismissError()
                }
            } message: {
                if let error = errorHandler.currentError {
                    VStack(alignment: .leading) {
                        Text(error.localizedDescription)
                        if let suggestion = error.recoverySuggestion {
                            Text(suggestion)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
    }
}

// MARK: - 错误处理视图修饰符
struct ErrorHandlingViewModifier: ViewModifier {
    @StateObject private var errorHandler = ErrorHandler.shared
    
    func body(content: Content) -> some View {
        content
            .alert("错误", isPresented: $errorHandler.showingError) {
                Button("确定") {
                    errorHandler.dismissError()
                }
            } message: {
                if let error = errorHandler.currentError {
                    VStack(alignment: .leading) {
                        Text(error.localizedDescription)
                        if let suggestion = error.recoverySuggestion {
                            Text(suggestion)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
    }
}

extension View {
    func errorHandling() -> some View {
        modifier(ErrorHandlingViewModifier())
    }
} 