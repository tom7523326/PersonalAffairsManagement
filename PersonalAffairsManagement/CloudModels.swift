//
//  CloudModels.swift
//  PersonalAffairsManagement
//
//  Created by 汤寿麟 on 2025/6/23.
//

import Foundation
import FirebaseFirestore

// MARK: - 云端项目模型
struct CloudProject: CloudModel, Codable {
    @DocumentID var id: String?
    let name: String
    let colorHex: String
    let createdAt: Date
    var updatedAt: Date
    
    init(from localProject: Project) {
        self.id = localProject.id.uuidString
        self.name = localProject.name
        self.colorHex = localProject.colorHex
        self.createdAt = localProject.createdAt
        self.updatedAt = Date()
    }
}

// MARK: - 云端任务模型
struct CloudWorkTask: CloudModel, Codable {
    @DocumentID var id: String?
    let title: String
    let taskDescription: String
    let priority: TaskPriority
    let status: TaskStatus
    let dueDate: Date?
    let createdAt: Date
    let completedAt: Date?
    let reminderDate: Date?
    let repeatRule: RepeatRule?
    let repeatInterval: Int
    let projectId: String?
    let parentTaskId: String?
    var updatedAt: Date
    
    init(from localTask: WorkTask) {
        self.id = localTask.id.uuidString
        self.title = localTask.title
        self.taskDescription = localTask.taskDescription
        self.priority = localTask.priority
        self.status = localTask.status
        self.dueDate = localTask.dueDate
        self.createdAt = localTask.createdAt
        self.completedAt = localTask.completedAt
        self.reminderDate = localTask.reminderDate
        self.repeatRule = localTask.repeatRule
        self.repeatInterval = localTask.repeatInterval
        self.projectId = localTask.project?.id.uuidString
        self.parentTaskId = localTask.parentTask?.id.uuidString
        self.updatedAt = Date()
    }
}

// MARK: - 云端财务记录模型
struct CloudFinancialRecord: CloudModel, Codable {
    @DocumentID var id: String?
    let title: String
    let amount: Double
    let type: TransactionType
    let category: FinancialCategory
    let date: Date
    let recordDescription: String
    let tags: [String]
    let createdAt: Date
    var updatedAt: Date
    
    init(from localRecord: FinancialRecord) {
        self.id = localRecord.id.uuidString
        self.title = localRecord.title
        self.amount = localRecord.amount
        self.type = localRecord.type
        self.category = localRecord.category
        self.date = localRecord.date
        self.recordDescription = localRecord.recordDescription
        self.tags = localRecord.tags
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

// MARK: - 云端预算模型
struct CloudBudget: CloudModel, Codable {
    @DocumentID var id: String?
    let name: String
    let amount: Double
    var spent: Double
    let period: BudgetPeriod
    let startDate: Date
    let endDate: Date
    let category: FinancialCategory
    let createdAt: Date
    var updatedAt: Date
    
    init(from localBudget: Budget) {
        self.id = localBudget.id.uuidString
        self.name = localBudget.name
        self.amount = localBudget.amount
        self.spent = localBudget.spent
        self.period = localBudget.period
        self.startDate = localBudget.startDate
        self.endDate = localBudget.endDate
        self.category = localBudget.category
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

// MARK: - 云端密码模型
struct CloudPasswordEntry: CloudModel, Codable {
    @DocumentID var id: String?
    let title: String
    let username: String
    let password: String // 注意：实际应用中密码应加密处理
    let website: String?
    let notes: String?
    let category: PasswordCategory
    let createdAt: Date
    var updatedAt: Date
    let isFavorite: Bool
    
    init(from localPassword: PasswordEntry) {
        self.id = localPassword.id.uuidString
        self.title = localPassword.title
        self.username = localPassword.username
        self.password = localPassword.password
        self.website = localPassword.website
        self.notes = localPassword.notes
        self.category = localPassword.category
        self.createdAt = localPassword.createdAt
        self.updatedAt = localPassword.updatedAt
        self.isFavorite = localPassword.isFavorite
    }
}

// MARK: - 云端虚拟资产模型
struct CloudVirtualAsset: CloudModel, Codable {
    @DocumentID var id: String?
    let name: String
    let assetType: AssetType
    let value: Double
    let currency: String
    let expiryDate: Date?
    let assetDescription: String?
    let barcode: String?
    let isActive: Bool
    let createdAt: Date
    var updatedAt: Date
    
    init(from localAsset: VirtualAsset) {
        self.id = localAsset.id.uuidString
        self.name = localAsset.name
        self.assetType = localAsset.assetType
        self.value = localAsset.value
        self.currency = localAsset.currency
        self.expiryDate = localAsset.expiryDate
        self.assetDescription = localAsset.assetDescription
        self.barcode = localAsset.barcode
        self.isActive = localAsset.isActive
        self.createdAt = localAsset.createdAt
        self.updatedAt = localAsset.updatedAt
    }
} 