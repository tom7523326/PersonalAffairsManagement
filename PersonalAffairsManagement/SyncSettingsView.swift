//
//  SyncSettingsView.swift
//  PersonalAffairsManagement
//
//  Created by 汤寿麟 on 2025/6/23.
//

import SwiftUI
import SwiftData

struct SyncSettingsView: View {
    @StateObject private var cloudService = CloudService.shared
    @EnvironmentObject private var syncManager: DataSyncManager
    @Environment(\.modelContext) private var modelContext
    
    @State private var showAuthentication = false
    @State private var showLogoutAlert = false
    @State private var showSyncAlert = false
    @State private var isAutoSyncEnabled = false
    
    var body: some View {
        NavigationView {
            List {
                // 认证状态
                Section("账户状态") {
                    HStack {
                        Image(systemName: cloudService.isAuthenticated ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(cloudService.isAuthenticated ? .green : .red)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(cloudService.isAuthenticated ? "已登录" : "未登录")
                                .font(.headline)
                            
                            if let user = cloudService.currentUser {
                                Text(user.email ?? "未知邮箱")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Spacer()
                        
                        if cloudService.isAuthenticated {
                            Button("退出登录") {
                                showLogoutAlert = true
                            }
                            .foregroundColor(.red)
                        } else {
                            Button("登录") {
                                showAuthentication = true
                            }
                            .foregroundColor(.blue)
                        }
                    }
                }
                
                // 同步状态
                if cloudService.isAuthenticated {
                    Section("同步状态") {
                        HStack {
                            Image(systemName: syncManager.isSyncing ? "arrow.triangle.2.circlepath" : "checkmark.circle.fill")
                                .foregroundColor(syncManager.isSyncing ? .orange : .green)
                                .rotationEffect(.degrees(syncManager.isSyncing ? 360 : 0))
                                .animation(syncManager.isSyncing ? .linear(duration: 1).repeatForever(autoreverses: false) : .default, value: syncManager.isSyncing)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(syncManager.isSyncing ? "同步中..." : "同步完成")
                                    .font(.headline)
                                
                                if let lastSync = syncManager.lastSyncDate {
                                    Text("上次同步: \(lastSync.formatted())")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            Spacer()
                            
                            if syncManager.isSyncing {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                                    .scaleEffect(0.8)
                            }
                        }
                        
                        if let error = syncManager.syncError {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.red)
                                
                                Text("同步错误: \(error)")
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    
                    // 同步选项
                    Section("同步选项") {
                        Button(action: performManualSync) {
                            HStack {
                                Image(systemName: "arrow.triangle.2.circlepath")
                                Text("立即同步")
                            }
                        }
                        .disabled(syncManager.isSyncing)
                        
                        Button(action: {
                            showSyncAlert = true
                        }) {
                            HStack {
                                Image(systemName: "trash")
                                Text("清空云端数据")
                            }
                            .foregroundColor(.red)
                        }
                    }
                    
                    // 数据统计
                    Section("数据统计") {
                        DataStatisticsView()
                    }
                }
                
                // 帮助信息
                Section("帮助") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("云端同步功能")
                            .font(.headline)
                        
                        Text("• 您的数据将安全存储在云端")
                        Text("• 支持多设备数据同步")
                        Text("• 自动备份防止数据丢失")
                        Text("• 离线时数据仍可正常使用")
                        
                        Text("隐私说明")
                            .font(.headline)
                            .padding(.top, 8)
                        
                        Text("• 所有数据均经过加密传输")
                        Text("• 只有您能访问您的数据")
                        Text("• 我们不会查看您的个人信息")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
            }
            .navigationTitle("云端同步")
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $showAuthentication) {
            AuthenticationView()
        }
        .alert("退出登录", isPresented: $showLogoutAlert) {
            Button("取消", role: .cancel) { }
            Button("退出", role: .destructive) {
                logout()
            }
        } message: {
            Text("确定要退出登录吗？您的本地数据将保留。")
        }
        .alert("清空云端数据", isPresented: $showSyncAlert) {
            Button("取消", role: .cancel) { }
            Button("清空", role: .destructive) {
                clearCloudData()
            }
        } message: {
            Text("此操作将删除云端所有数据，且无法恢复。确定继续吗？")
        }
    }
    
    // MARK: - 方法
    private func performManualSync() {
        Task {
            await syncManager.performFullSync()
        }
    }
    
    private func logout() {
        do {
            try cloudService.signOut()
        } catch {
            print("退出登录失败: \(error)")
        }
    }
    
    private func clearCloudData() {
        // 实现清空云端数据的逻辑
        Task {
            // 这里需要实现清空云端数据的功能
            print("清空云端数据")
        }
    }
}

// MARK: - 数据统计视图
struct DataStatisticsView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var statistics: [String: Int] = [:]
    
    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            StatCard(title: "任务", value: "\(statistics["tasks"] ?? 0)", icon: "checklist", color: .blue)
            StatCard(title: "项目", value: "\(statistics["projects"] ?? 0)", icon: "folder", color: .green)
            StatCard(title: "财务记录", value: "\(statistics["financial"] ?? 0)", icon: "banknote", color: .orange)
            StatCard(title: "密码", value: "\(statistics["passwords"] ?? 0)", icon: "key", color: .purple)
        }
        .onAppear {
            loadStatistics()
        }
    }
    
    private func loadStatistics() {
        do {
            let tasks = try modelContext.fetch(FetchDescriptor<WorkTask>())
            let projects = try modelContext.fetch(FetchDescriptor<Project>())
            let financialRecords = try modelContext.fetch(FetchDescriptor<FinancialRecord>())
            let passwords = try modelContext.fetch(FetchDescriptor<PasswordEntry>())
            
            statistics = [
                "tasks": tasks.count,
                "projects": projects.count,
                "financial": financialRecords.count,
                "passwords": passwords.count
            ]
        } catch {
            print("加载统计数据失败: \(error)")
        }
    }
}

#Preview {
    SyncSettingsView()
        .modelContainer(for: [WorkTask.self, Project.self, FinancialRecord.self, PasswordEntry.self], inMemory: true)
} 