//
//  Models.swift
//  PersonalAffairsManagement
//
//  Created by 汤寿麟 on 2025/6/23.
//

import Foundation
import SwiftData
import SwiftUI

// MARK: - 清单/项目模型
@Model
final class Project {
    @Attribute(.unique) var id: UUID
    var name: String
    var colorHex: String // 存储颜色的十六进制字符串
    var createdAt: Date
    
    // 使用 @Relationship 来管理一对多关系
    // a project can have many tasks
    @Relationship(deleteRule: .cascade, inverse: \WorkTask.project)
    var tasks: [WorkTask]?
    
    init(name: String, colorHex: String) {
        self.id = UUID()
        self.name = name
        self.colorHex = colorHex
        self.createdAt = Date()
    }
    
    var color: Color {
        Color(hex: colorHex) ?? .gray
    }
}

// MARK: - 工作事务模型
@Model
final class WorkTask {
    @Attribute(.unique) var id: UUID
    var title: String
    var taskDescription: String
    var priority: TaskPriority
    var status: TaskStatus
    var dueDate: Date?
    var createdAt: Date
    var completedAt: Date?
    
    // Reminder and repeat functionality
    var reminderDate: Date?
    var repeatRule: RepeatRule?
    var repeatInterval: Int = 1
    
    // 关系
    var project: Project?
    
    // For subtasks
    var parentTask: WorkTask?
    
    @Relationship(deleteRule: .cascade, inverse: \WorkTask.parentTask)
    var subtasks: [WorkTask]?
    
    init(title: String, taskDescription: String = "", priority: TaskPriority = .medium, dueDate: Date? = nil, project: Project? = nil) {
        self.id = UUID()
        self.title = title
        self.taskDescription = taskDescription
        self.priority = priority
        self.status = .pending
        self.dueDate = dueDate
        self.createdAt = Date()
        self.project = project
    }
}

enum TaskPriority: String, CaseIterable, Codable, Hashable {
    case low = "低"
    case medium = "中"
    case high = "高"
    case urgent = "紧急"
    
    var color: Color {
        switch self {
        case .low: return .green
        case .medium: return .blue
        case .high: return .orange
        case .urgent: return .red
        }
    }
}

enum TaskStatus: String, CaseIterable, Codable, CustomStringConvertible {
    case pending = "待处理"
    case inProgress = "进行中"
    case completed = "已完成"
    case cancelled = "已取消"

    var description: String {
        return self.rawValue
    }
}

enum RepeatRule: String, CaseIterable, Codable, Hashable {
    case daily = "每天"
    case weekly = "每周"
    case monthly = "每月"
    case yearly = "每年"
    case weekdays = "工作日"
    case weekends = "周末"
    
    func nextDate(from date: Date) -> Date {
        let calendar = Calendar.current
        switch self {
        case .daily:
            return calendar.date(byAdding: .day, value: 1, to: date) ?? date
        case .weekly:
            return calendar.date(byAdding: .weekOfYear, value: 1, to: date) ?? date
        case .monthly:
            return calendar.date(byAdding: .month, value: 1, to: date) ?? date
        case .yearly:
            return calendar.date(byAdding: .year, value: 1, to: date) ?? date
        case .weekdays:
            var nextDate = calendar.date(byAdding: .day, value: 1, to: date) ?? date
            while calendar.isDateInWeekend(nextDate) {
                nextDate = calendar.date(byAdding: .day, value: 1, to: nextDate) ?? nextDate
            }
            return nextDate
        case .weekends:
            var nextDate = calendar.date(byAdding: .day, value: 1, to: date) ?? date
            while !calendar.isDateInWeekend(nextDate) {
                nextDate = calendar.date(byAdding: .day, value: 1, to: nextDate) ?? nextDate
            }
            return nextDate
        }
    }
}

// MARK: - 财务管理模型
@Model
final class FinancialRecord {
    var id: UUID
    var title: String
    var amount: Double
    var type: TransactionType
    var category: FinancialCategory
    var date: Date
    var recordDescription: String
    var tags: [String]
    
    init(title: String, amount: Double, type: TransactionType, category: FinancialCategory, recordDescription: String = "") {
        self.id = UUID()
        self.title = title
        self.amount = amount
        self.type = type
        self.category = category
        self.date = Date()
        self.recordDescription = recordDescription
        self.tags = []
    }
}

enum FinancialCategory: String, Codable, CaseIterable, CustomStringConvertible {
    case income = "收入"
    case housing = "住房"
    case transportation = "交通"
    case food = "餐饮"
    case utilities = "生活缴费"
    case shopping = "购物"
    case entertainment = "娱乐"
    case health = "医疗健康"
    case education = "教育"
    case travel = "旅行"
    case other = "其他"
    
    var description: String {
        return self.rawValue
    }
}

enum TransactionType: String, CaseIterable, Codable {
    case income = "收入"
    case expense = "支出"
    
    var color: String {
        switch self {
        case .income: return "green"
        case .expense: return "red"
        }
    }
}

// MARK: - 预算模型
@Model
final class Budget {
    var id: UUID
    var name: String
    var amount: Double
    var spent: Double
    var period: BudgetPeriod
    var startDate: Date
    var endDate: Date
    var category: FinancialCategory
    
    init(name: String, amount: Double, period: BudgetPeriod, category: FinancialCategory) {
        self.id = UUID()
        self.name = name
        self.amount = amount
        self.spent = 0.0
        self.period = period
        self.startDate = Date()
        self.endDate = period.endDate(from: Date())
        self.category = category
    }
    
    // 计算属性
    var remaining: Double {
        return amount - spent
    }
    
    var progress: Double {
        return amount > 0 ? min(spent / amount, 1.0) : 0.0
    }
    
    var isOverBudget: Bool {
        return spent > amount
    }
    
    var isExpired: Bool {
        return Date() > endDate
    }
    
    // 更新花费金额的方法
    func updateSpent(_ newSpent: Double) {
        self.spent = newSpent
    }
}

enum BudgetPeriod: String, CaseIterable, Codable {
    case weekly = "周"
    case monthly = "月"
    case yearly = "年"
    
    func endDate(from startDate: Date) -> Date {
        let calendar = Calendar.current
        switch self {
        case .weekly:
            return calendar.date(byAdding: .weekOfYear, value: 1, to: startDate) ?? startDate
        case .monthly:
            return calendar.date(byAdding: .month, value: 1, to: startDate) ?? startDate
        case .yearly:
            return calendar.date(byAdding: .year, value: 1, to: startDate) ?? startDate
        }
    }
}

// MARK: - 个人密码箱模型
@Model
final class PasswordEntry {
    @Attribute(.unique) var id: UUID
    var title: String
    var username: String
    var password: String
    var website: String?
    var notes: String?
    var category: PasswordCategory
    var createdAt: Date
    var updatedAt: Date
    var isFavorite: Bool
    
    init(title: String, username: String, password: String, website: String? = nil, notes: String? = nil, category: PasswordCategory = .other) {
        self.id = UUID()
        self.title = title
        self.username = username
        self.password = password
        self.website = website
        self.notes = notes
        self.category = category
        self.createdAt = Date()
        self.updatedAt = Date()
        self.isFavorite = false
    }
}

enum PasswordCategory: String, CaseIterable, Codable {
    case social = "社交媒体"
    case email = "邮箱"
    case banking = "银行金融"
    case shopping = "购物网站"
    case work = "工作相关"
    case entertainment = "娱乐"
    case other = "其他"
    
    var icon: String {
        switch self {
        case .social: return "person.2.fill"
        case .email: return "envelope.fill"
        case .banking: return "banknote.fill"
        case .shopping: return "cart.fill"
        case .work: return "briefcase.fill"
        case .entertainment: return "gamecontroller.fill"
        case .other: return "key.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .social: return .blue
        case .email: return .green
        case .banking: return .orange
        case .shopping: return .purple
        case .work: return .gray
        case .entertainment: return .pink
        case .other: return .secondary
        }
    }
}

// MARK: - 虚拟资产模型
@Model
final class VirtualAsset {
    @Attribute(.unique) var id: UUID
    var name: String
    var assetType: AssetType
    var value: Double
    var currency: String
    var expiryDate: Date?
    var assetDescription: String?
    var barcode: String?
    var isActive: Bool
    var createdAt: Date
    var updatedAt: Date
    
    init(name: String, assetType: AssetType, value: Double, currency: String = "CNY", expiryDate: Date? = nil, assetDescription: String? = nil, barcode: String? = nil) {
        self.id = UUID()
        self.name = name
        self.assetType = assetType
        self.value = value
        self.currency = currency
        self.expiryDate = expiryDate
        self.assetDescription = assetDescription
        self.barcode = barcode
        self.isActive = true
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

enum AssetType: String, CaseIterable, Codable {
    case giftCard = "礼品卡"
    case coupon = "优惠券"
    case voucher = "代金券"
    case membership = "会员卡"
    case loyalty = "积分卡"
    case other = "其他"
    
    var icon: String {
        switch self {
        case .giftCard: return "creditcard.fill"
        case .coupon: return "ticket.fill"
        case .voucher: return "doc.text.fill"
        case .membership: return "person.badge.plus.fill"
        case .loyalty: return "star.fill"
        case .other: return "square.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .giftCard: return .blue
        case .coupon: return .green
        case .voucher: return .orange
        case .membership: return .purple
        case .loyalty: return .yellow
        case .other: return .gray
        }
    }
}

// MARK: - 扩展
extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0

        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 1.0

        let length = hexSanitized.count

        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }

        if length == 6 {
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x0000FF) / 255.0
        } else if length == 8 {
            r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            a = CGFloat(rgb & 0x000000FF) / 255.0
        } else {
            return nil
        }

        self.init(red: r, green: g, blue: b, opacity: a)
    }
} 