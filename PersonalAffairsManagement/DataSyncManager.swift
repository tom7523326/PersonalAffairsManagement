//
//  DataSyncManager.swift
//  PersonalAffairsManagement
//
//  Created by 汤寿麟 on 2025/6/23.
//

import Foundation
import SwiftData
import Combine

// MARK: - 数据同步管理器
class DataSyncManager: ObservableObject {
    private let modelContext: ModelContext
    // 延迟初始化 CloudService，只有在真正需要时才创建
    private lazy var cloudService: CloudService = {
        return CloudService.shared
    }()
    private var cancellables = Set<AnyCancellable>()
    
    @Published var syncProgress: Double = 0.0
    @Published var isSyncing = false
    @Published var lastSyncDate: Date?
    @Published var syncError: String?
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        // 暂时不设置观察者，等 Firebase 配置完成后再设置
        // setupCloudServiceObserver()
    }
    
    // MARK: - 初始化 Firebase 相关服务
    func initializeFirebaseServices() {
        cloudService.initializeFirebaseServices()
        setupCloudServiceObserver()
    }
    
    // MARK: - 设置观察者
    private func setupCloudServiceObserver() {
        cloudService.$syncStatus
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                // 这里可以根据需要处理状态更新，比如显示在UI上
                // 例如：self.currentSyncStatusMessage = status
            }
            .store(in: &cancellables)
    }
    
    // MARK: - 全量同步
    func performFullSync() async {
        guard cloudService.isAuthenticated else {
            syncError = "用户未认证"
            return
        }
        
        do {
            // 1. 上传本地数据到云端
            try await uploadLocalDataToCloud()
            
            // 2. 从云端下载数据到本地
            try await downloadCloudDataToLocal()
            
            // 3. 更新同步时间
            lastSyncDate = Date()
            
        } catch {
            syncError = error.localizedDescription
        }
    }
    
    // MARK: - 上传本地数据到云端
    private func uploadLocalDataToCloud() async throws {
        print("[DataSyncManager] 开始上传本地数据到云端")
        
        // 获取所有本地数据
        let projects = try modelContext.fetch(FetchDescriptor<Project>())
        let tasks = try modelContext.fetch(FetchDescriptor<WorkTask>())
        let financialRecords = try modelContext.fetch(FetchDescriptor<FinancialRecord>())
        let budgets = try modelContext.fetch(FetchDescriptor<Budget>())
        let passwords = try modelContext.fetch(FetchDescriptor<PasswordEntry>())
        let virtualAssets = try modelContext.fetch(FetchDescriptor<VirtualAsset>())
        
        print("[DataSyncManager] 本地数据统计：")
        print("  - 项目: \(projects.count) 个")
        print("  - 任务: \(tasks.count) 个")
        print("  - 财务记录: \(financialRecords.count) 条")
        print("  - 预算: \(budgets.count) 个")
        print("  - 密码: \(passwords.count) 个")
        print("  - 虚拟资产: \(virtualAssets.count) 个")
        
        // 转换为云端模型
        let cloudProjects = projects.map { CloudProject(from: $0) }
        let cloudTasks = tasks.map { CloudWorkTask(from: $0) }
        let cloudFinancialRecords = financialRecords.map { CloudFinancialRecord(from: $0) }
        let cloudBudgets = budgets.map { CloudBudget(from: $0) }
        let cloudPasswords = passwords.map { CloudPasswordEntry(from: $0) }
        let cloudVirtualAssets = virtualAssets.map { CloudVirtualAsset(from: $0) }
        
        print("[DataSyncManager] 云端模型转换完成")
        
        // 批量上传到云端
        print("[DataSyncManager] 开始上传项目数据...")
        try await cloudService.syncData(cloudProjects, collection: "projects")
        
        print("[DataSyncManager] 开始上传任务数据...")
        try await cloudService.syncData(cloudTasks, collection: "tasks")
        
        print("[DataSyncManager] 开始上传财务记录数据...")
        try await cloudService.syncData(cloudFinancialRecords, collection: "financialRecords")
        
        print("[DataSyncManager] 开始上传预算数据...")
        try await cloudService.syncData(cloudBudgets, collection: "budgets")
        
        print("[DataSyncManager] 开始上传密码数据...")
        try await cloudService.syncData(cloudPasswords, collection: "passwords")
        
        print("[DataSyncManager] 开始上传虚拟资产数据...")
        try await cloudService.syncData(cloudVirtualAssets, collection: "virtualAssets")
        
        print("[DataSyncManager] 所有数据上传完成")
    }
    
    // MARK: - 从云端下载数据到本地
    private func downloadCloudDataToLocal() async throws {
        // 在这里按顺序获取所有云端数据
        // 注意：这里我们忽略了错误处理的细节，实际应用中需要更完善的错误处理
        let cloudProjects: [CloudProject] = try await cloudService.fetchData(collection: "projects")
        let cloudTasks: [CloudWorkTask] = try await cloudService.fetchData(collection: "tasks")
        let cloudFinancialRecords: [CloudFinancialRecord] = try await cloudService.fetchData(collection: "financialRecords")
        let cloudBudgets: [CloudBudget] = try await cloudService.fetchData(collection: "budgets")
        let cloudPasswords: [CloudPasswordEntry] = try await cloudService.fetchData(collection: "passwords")
        let cloudVirtualAssets: [CloudVirtualAsset] = try await cloudService.fetchData(collection: "virtualAssets")
        
        // 清空本地数据（可选，取决于同步策略）
        // clearLocalData(modelContext: modelContext)
        
        // 将云端数据转换为本地模型并保存
        try await saveCloudProjectsToLocal(cloudProjects)
        try await saveCloudTasksToLocal(cloudTasks)
        try await saveCloudFinancialRecordsToLocal(cloudFinancialRecords)
        try await saveCloudBudgetsToLocal(cloudBudgets)
        try await saveCloudPasswordsToLocal(cloudPasswords)
        try await saveCloudVirtualAssetsToLocal(cloudVirtualAssets)
    }
    
    // MARK: - 保存云端项目到本地
    private func saveCloudProjectsToLocal(_ cloudProjects: [CloudProject]) async throws {
        for cloudProject in cloudProjects {
            guard let idString = cloudProject.id, let projectId = UUID(uuidString: idString) else { continue }
            let fetch = FetchDescriptor<Project>(predicate: #Predicate { $0.id == projectId })
            let existing = try modelContext.fetch(fetch).first
            if let local = existing {
                local.name = cloudProject.name
                local.colorHex = cloudProject.colorHex
                local.createdAt = cloudProject.createdAt
            } else {
                let project = Project(name: cloudProject.name, colorHex: cloudProject.colorHex)
                project.id = projectId
                project.createdAt = cloudProject.createdAt
                modelContext.insert(project)
            }
        }
        try modelContext.save()
    }
    
    // MARK: - 保存云端任务到本地
    private func saveCloudTasksToLocal(_ cloudTasks: [CloudWorkTask]) async throws {
        let projects = try modelContext.fetch(FetchDescriptor<Project>())
        let projectMap = Dictionary(uniqueKeysWithValues: projects.map { ($0.id.uuidString, $0) })
        for cloudTask in cloudTasks {
            guard let idString = cloudTask.id, let taskId = UUID(uuidString: idString) else { continue }
            let fetch = FetchDescriptor<WorkTask>(predicate: #Predicate { $0.id == taskId })
            let existing = try modelContext.fetch(fetch).first
            if let local = existing {
                local.title = cloudTask.title
                local.taskDescription = cloudTask.taskDescription
                local.priority = cloudTask.priority
                local.dueDate = cloudTask.dueDate
                local.status = cloudTask.status
                local.createdAt = cloudTask.createdAt
                local.completedAt = cloudTask.completedAt
                local.reminderDate = cloudTask.reminderDate
                local.repeatRule = cloudTask.repeatRule
                local.repeatInterval = cloudTask.repeatInterval
                if let projectId = cloudTask.projectId {
                    local.project = projectMap[projectId]
                }
            } else {
                let task = WorkTask(
                    title: cloudTask.title,
                    taskDescription: cloudTask.taskDescription,
                    priority: cloudTask.priority,
                    dueDate: cloudTask.dueDate
                )
                task.id = taskId
                task.status = cloudTask.status
                task.createdAt = cloudTask.createdAt
                task.completedAt = cloudTask.completedAt
                task.reminderDate = cloudTask.reminderDate
                task.repeatRule = cloudTask.repeatRule
                task.repeatInterval = cloudTask.repeatInterval
                if let projectId = cloudTask.projectId {
                    task.project = projectMap[projectId]
                }
                modelContext.insert(task)
            }
        }
        try modelContext.save()
    }
    
    // MARK: - 保存云端财务记录到本地
    private func saveCloudFinancialRecordsToLocal(_ cloudRecords: [CloudFinancialRecord]) async throws {
        for cloudRecord in cloudRecords {
            guard let idString = cloudRecord.id, let recordId = UUID(uuidString: idString) else { continue }
            let fetch = FetchDescriptor<FinancialRecord>(predicate: #Predicate { $0.id == recordId })
            let existing = try modelContext.fetch(fetch).first
            if let local = existing {
                local.title = cloudRecord.title
                local.amount = cloudRecord.amount
                local.type = cloudRecord.type
                local.category = cloudRecord.category
                local.recordDescription = cloudRecord.recordDescription
                local.date = cloudRecord.date
                local.tags = cloudRecord.tags
            } else {
                let record = FinancialRecord(
                    title: cloudRecord.title,
                    amount: cloudRecord.amount,
                    type: cloudRecord.type,
                    category: cloudRecord.category,
                    recordDescription: cloudRecord.recordDescription
                )
                record.id = recordId
                record.date = cloudRecord.date
                record.tags = cloudRecord.tags
                modelContext.insert(record)
            }
        }
        try modelContext.save()
    }
    
    // MARK: - 保存云端预算到本地
    private func saveCloudBudgetsToLocal(_ cloudBudgets: [CloudBudget]) async throws {
        for cloudBudget in cloudBudgets {
            guard let idString = cloudBudget.id, let budgetId = UUID(uuidString: idString) else { continue }
            let fetch = FetchDescriptor<Budget>(predicate: #Predicate { $0.id == budgetId })
            let existing = try modelContext.fetch(fetch).first
            if let local = existing {
                local.name = cloudBudget.name
                local.amount = cloudBudget.amount
                local.period = cloudBudget.period
                local.category = cloudBudget.category
                local.spent = cloudBudget.spent
                local.startDate = cloudBudget.startDate
                local.endDate = cloudBudget.endDate
            } else {
                let budget = Budget(
                    name: cloudBudget.name,
                    amount: cloudBudget.amount,
                    period: cloudBudget.period,
                    category: cloudBudget.category
                )
                budget.id = budgetId
                budget.spent = cloudBudget.spent
                budget.startDate = cloudBudget.startDate
                budget.endDate = cloudBudget.endDate
                modelContext.insert(budget)
            }
        }
        try modelContext.save()
    }
    
    // MARK: - 保存云端密码到本地
    private func saveCloudPasswordsToLocal(_ cloudPasswords: [CloudPasswordEntry]) async throws {
        for cloudPassword in cloudPasswords {
            guard let idString = cloudPassword.id, let passwordId = UUID(uuidString: idString) else { continue }
            let fetch = FetchDescriptor<PasswordEntry>(predicate: #Predicate { $0.id == passwordId })
            let existing = try modelContext.fetch(fetch).first
            if let local = existing {
                local.title = cloudPassword.title
                local.username = cloudPassword.username
                local.password = cloudPassword.password
                local.website = cloudPassword.website
                local.notes = cloudPassword.notes
                local.category = cloudPassword.category
                local.createdAt = cloudPassword.createdAt
                local.updatedAt = cloudPassword.updatedAt
                local.isFavorite = cloudPassword.isFavorite
            } else {
                let password = PasswordEntry(
                    title: cloudPassword.title,
                    username: cloudPassword.username,
                    password: cloudPassword.password,
                    website: cloudPassword.website,
                    notes: cloudPassword.notes,
                    category: cloudPassword.category
                )
                password.id = passwordId
                password.createdAt = cloudPassword.createdAt
                password.updatedAt = cloudPassword.updatedAt
                password.isFavorite = cloudPassword.isFavorite
                modelContext.insert(password)
            }
        }
        try modelContext.save()
    }
    
    // MARK: - 保存云端虚拟资产到本地
    private func saveCloudVirtualAssetsToLocal(_ cloudAssets: [CloudVirtualAsset]) async throws {
        for cloudAsset in cloudAssets {
            guard let idString = cloudAsset.id, let assetId = UUID(uuidString: idString) else { continue }
            let fetch = FetchDescriptor<VirtualAsset>(predicate: #Predicate { $0.id == assetId })
            let existing = try modelContext.fetch(fetch).first
            if let local = existing {
                local.name = cloudAsset.name
                local.assetType = cloudAsset.assetType
                local.value = cloudAsset.value
                local.currency = cloudAsset.currency
                local.expiryDate = cloudAsset.expiryDate
                local.assetDescription = cloudAsset.assetDescription
                local.barcode = cloudAsset.barcode
                local.createdAt = cloudAsset.createdAt
                local.updatedAt = cloudAsset.updatedAt
                local.isActive = cloudAsset.isActive
            } else {
                let asset = VirtualAsset(
                    name: cloudAsset.name,
                    assetType: cloudAsset.assetType,
                    value: cloudAsset.value,
                    currency: cloudAsset.currency,
                    expiryDate: cloudAsset.expiryDate,
                    assetDescription: cloudAsset.assetDescription,
                    barcode: cloudAsset.barcode
                )
                asset.id = assetId
                asset.createdAt = cloudAsset.createdAt
                asset.updatedAt = cloudAsset.updatedAt
                asset.isActive = cloudAsset.isActive
                modelContext.insert(asset)
            }
        }
        try modelContext.save()
    }
    
    // MARK: - 清空本地数据（可选）
    private func clearLocalData(modelContext: ModelContext) {
        // 注意：这会删除所有本地数据，请谨慎使用
        // 在实际应用中，你可能需要更智能的合并策略
    }
    
    // MARK: - 增量同步
    func performIncrementalSync(modelContext: ModelContext) async {
        // 实现增量同步逻辑
        // 只同步自上次同步以来发生变化的数据
    }
} 