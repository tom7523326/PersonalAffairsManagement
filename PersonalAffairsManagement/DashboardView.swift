//
//  DashboardView.swift
//  PersonalAffairsManagement
//
//  Created by 汤寿麟 on 2025/6/23.
//

import SwiftUI
import SwiftData
import Charts

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var tasks: [WorkTask]
    @Query private var financialRecords: [FinancialRecord]
    @Query private var budgets: [Budget]
    @Query private var passwords: [PasswordEntry]
    @Query private var virtualAssets: [VirtualAsset]
    
    @State private var selectedTimeRange: TimeRange = .week
    @State private var showingAddSheet = false
    @State private var selectedAddType: AddSheetType = .task
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: DesignSystem.Spacing.lg) {
                // 欢迎区域
                welcomeSection
                
                // 快速操作
                quickActionsSection
                
                // 统计概览
                statisticsSection
                
                // 任务完成情况
                taskCompletionSection
                
                // 财务概览
                financialOverviewSection
                
                // 预算状态
                budgetStatusSection
                
                // 最近活动
                recentActivitySection
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
        }
        .background(DesignSystem.Colors.groupedBackground)
        .navigationTitle("仪表板")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingAddSheet = true }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(DesignSystem.Colors.primary)
                }
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            AddItemSheet(type: selectedAddType)
        }
    }
    
    // MARK: - 欢迎区域
    private var welcomeSection: some View {
        ModernCard(shadow: DesignSystem.Shadows.medium) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                HStack {
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                        Text("欢迎回来")
                            .font(DesignSystem.Typography.title2)
                            .foregroundColor(DesignSystem.Colors.text)
                        
                        Text("今天是 \(Date().formatted(date: .complete, time: .omitted))")
                            .font(DesignSystem.Typography.body)
                            .foregroundColor(DesignSystem.Colors.secondaryText)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "sun.max.fill")
                        .font(.title)
                        .foregroundColor(DesignSystem.Colors.accent)
                }
                
                // 今日概览
                HStack(spacing: DesignSystem.Spacing.lg) {
                    StatItem(
                        icon: "checkmark.circle.fill",
                        value: "\(todayCompletedTasks)",
                        label: "已完成",
                        color: DesignSystem.Colors.success
                    )
                    
                    StatItem(
                        icon: "clock.fill",
                        value: "\(todayPendingTasks)",
                        label: "待处理",
                        color: DesignSystem.Colors.warning
                    )
                    
                    StatItem(
                        icon: "exclamationmark.triangle.fill",
                        value: "\(overdueTasks)",
                        label: "已逾期",
                        color: DesignSystem.Colors.error
                    )
                }
            }
        }
    }
    
    // MARK: - 快速操作
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("快速操作")
                .font(DesignSystem.Typography.headline)
                .foregroundColor(DesignSystem.Colors.text)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: DesignSystem.Spacing.md) {
                QuickActionCard(
                    title: "添加任务",
                    icon: "checklist",
                    color: DesignSystem.Colors.task,
                    action: { 
                        selectedAddType = .task
                        showingAddSheet = true
                    }
                )
                
                QuickActionCard(
                    title: "记录收支",
                    icon: "dollarsign.circle",
                    color: DesignSystem.Colors.finance,
                    action: { 
                        selectedAddType = .financialRecord
                        showingAddSheet = true
                    }
                )
                
                QuickActionCard(
                    title: "保存密码",
                    icon: "lock.shield",
                    color: DesignSystem.Colors.password,
                    action: { 
                        selectedAddType = .password
                        showingAddSheet = true
                    }
                )
                
                QuickActionCard(
                    title: "管理资产",
                    icon: "creditcard",
                    color: DesignSystem.Colors.asset,
                    action: { 
                        selectedAddType = .virtualAsset
                        showingAddSheet = true
                    }
                )
            }
        }
    }
    
    // MARK: - 统计概览
    private var statisticsSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("数据概览")
                .font(DesignSystem.Typography.headline)
                .foregroundColor(DesignSystem.Colors.text)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: DesignSystem.Spacing.md) {
                StatCard(
                    title: "总任务",
                    value: "\(tasks.count)",
                    icon: "checklist",
                    color: DesignSystem.Colors.task
                )
                
                StatCard(
                    title: "总资产",
                    value: "¥\(Int(totalAssetValue))",
                    icon: "creditcard",
                    color: DesignSystem.Colors.asset
                )
                
                StatCard(
                    title: "密码数量",
                    value: "\(passwords.count)",
                    icon: "lock.shield",
                    color: DesignSystem.Colors.password
                )
                
                StatCard(
                    title: "本月收支",
                    value: "¥\(Int(monthlyNetIncome))",
                    icon: "dollarsign.circle",
                    color: monthlyNetIncome >= 0 ? DesignSystem.Colors.success : DesignSystem.Colors.error
                )
            }
        }
    }
    
    // MARK: - 任务完成情况
    private var taskCompletionSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            HStack {
                Text("任务完成情况")
                    .font(DesignSystem.Typography.headline)
                    .foregroundColor(DesignSystem.Colors.text)
                
                Spacer()
                
                Picker("时间范围", selection: $selectedTimeRange) {
                    ForEach(TimeRange.allCases, id: \.self) { range in
                        Text(range.title).tag(range)
                    }
                }
                .pickerStyle(MenuPickerStyle())
            }
            
            ModernCard {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                    // 任务完成率
                    HStack {
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                            Text("完成率")
                                .font(DesignSystem.Typography.body)
                                .foregroundColor(DesignSystem.Colors.secondaryText)
                            
                            Text("\(String(format: "%.1f", taskCompletionRate))%")
                                .font(DesignSystem.Typography.title2)
                                .fontWeight(.bold)
                                .foregroundColor(DesignSystem.Colors.text)
                        }
                        
                        Spacer()
                        
                        CircularProgressView(
                            progress: taskCompletionRate / 100,
                            color: DesignSystem.Colors.success
                        )
                    }
                    
                    // 任务完成趋势图
                    if !taskCompletionData.isEmpty {
                        Chart(taskCompletionData) { data in
                            BarMark(
                                x: .value("日期", data.date, unit: .day),
                                y: .value("完成数", data.completedCount)
                            )
                            .foregroundStyle(DesignSystem.Colors.success.gradient)
                        }
                        .frame(height: 200)
                        .chartXAxis {
                            AxisMarks(values: .stride(by: .day)) { value in
                                AxisGridLine()
                                AxisValueLabel(format: .dateTime.day())
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - 财务概览
    private var financialOverviewSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("财务概览")
                .font(DesignSystem.Typography.headline)
                .foregroundColor(DesignSystem.Colors.text)
            
            ModernCard {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                    HStack {
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                            Text("本月收入")
                                .font(DesignSystem.Typography.body)
                                .foregroundColor(DesignSystem.Colors.secondaryText)
                            
                            Text("¥\(monthlyIncome, specifier: "%.0f")")
                                .font(DesignSystem.Typography.title2)
                                .fontWeight(.bold)
                                .foregroundColor(DesignSystem.Colors.success)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: DesignSystem.Spacing.xs) {
                            Text("本月支出")
                                .font(DesignSystem.Typography.body)
                                .foregroundColor(DesignSystem.Colors.secondaryText)
                            
                            Text("¥\(monthlyExpense, specifier: "%.0f")")
                                .font(DesignSystem.Typography.title2)
                                .fontWeight(.bold)
                                .foregroundColor(DesignSystem.Colors.error)
                        }
                    }
                    
                    Divider()
                    
                    HStack {
                        Text("净收入")
                            .font(DesignSystem.Typography.body)
                            .foregroundColor(DesignSystem.Colors.secondaryText)
                        
                        Spacer()
                        
                        Text("¥\(monthlyNetIncome, specifier: "%.0f")")
                            .font(DesignSystem.Typography.title3)
                            .fontWeight(.bold)
                            .foregroundColor(monthlyNetIncome >= 0 ? DesignSystem.Colors.success : DesignSystem.Colors.error)
                    }
                }
            }
        }
    }
    
    // MARK: - 预算状态
    private var budgetStatusSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("预算状态")
                .font(DesignSystem.Typography.headline)
                .foregroundColor(DesignSystem.Colors.text)
            
            LazyVStack(spacing: DesignSystem.Spacing.sm) {
                ForEach(budgets.prefix(3)) { budget in
                    BudgetProgressCard(budget: budget, currentSpending: getCurrentSpending(for: budget))
                }
            }
        }
    }
    
    // MARK: - 最近活动
    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("最近活动")
                .font(DesignSystem.Typography.headline)
                .foregroundColor(DesignSystem.Colors.text)
            
            ModernCard {
                LazyVStack(spacing: DesignSystem.Spacing.sm) {
                    ForEach(recentActivities.prefix(5)) { activity in
                        ActivityRow(activity: activity)
                    }
                }
            }
        }
    }
    
    // MARK: - 计算属性
    private var todayCompletedTasks: Int {
        let today = Calendar.current.startOfDay(for: Date())
        return tasks.filter { task in
            task.status == .completed && 
            task.completedAt != nil &&
            Calendar.current.isDate(task.completedAt!, inSameDayAs: today)
        }.count
    }
    
    private var todayPendingTasks: Int {
        let today = Calendar.current.startOfDay(for: Date())
        return tasks.filter { task in
            task.status == .pending && 
            task.dueDate != nil &&
            Calendar.current.isDate(task.dueDate!, inSameDayAs: today)
        }.count
    }
    
    private var overdueTasks: Int {
        let today = Date()
        return tasks.filter { task in
            task.status == .pending && 
            task.dueDate != nil &&
            task.dueDate! < today
        }.count
    }
    
    private var taskCompletionRate: Double {
        let completed = tasks.filter { $0.status == .completed }.count
        let total = tasks.count
        return total > 0 ? Double(completed) / Double(total) * 100 : 0
    }
    
    private var taskCompletionData: [TaskCompletionData] {
        let calendar = Calendar.current
        let endDate = Date()
        let startDate = calendar.date(byAdding: .day, value: -6, to: endDate)!
        
        var data: [TaskCompletionData] = []
        var currentDate = startDate
        
        while currentDate <= endDate {
            let dayStart = calendar.startOfDay(for: currentDate)
            let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart)!
            
            let completedCount = tasks.filter { task in
                task.status == .completed &&
                task.completedAt != nil &&
                task.completedAt! >= dayStart &&
                task.completedAt! < dayEnd
            }.count
            
            data.append(TaskCompletionData(date: currentDate, completedCount: completedCount))
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        return data
    }
    
    private var monthlyIncome: Double {
        let calendar = Calendar.current
        let now = Date()
        let startOfMonth = calendar.dateInterval(of: .month, for: now)?.start ?? now
        
        return financialRecords.filter { record in
            record.type == .income && record.date >= startOfMonth
        }.reduce(0) { $0 + $1.amount }
    }
    
    private var monthlyExpense: Double {
        let calendar = Calendar.current
        let now = Date()
        let startOfMonth = calendar.dateInterval(of: .month, for: now)?.start ?? now
        
        return financialRecords.filter { record in
            record.type == .expense && record.date >= startOfMonth
        }.reduce(0) { $0 + $1.amount }
    }
    
    private var monthlyNetIncome: Double {
        return monthlyIncome - monthlyExpense
    }
    
    private var totalAssetValue: Double {
        return virtualAssets.reduce(0) { $0 + $1.value }
    }
    
    private var recentActivities: [Activity] {
        var activities: [Activity] = []
        
        // 最近完成的任务
        let recentCompletedTasks = tasks
            .filter { $0.status == .completed && $0.completedAt != nil }
            .sorted { $0.completedAt! > $1.completedAt! }
            .prefix(3)
        
        for task in recentCompletedTasks {
            activities.append(Activity(
                id: task.id.uuidString,
                title: "完成任务",
                subtitle: task.title,
                icon: "checkmark.circle.fill",
                color: DesignSystem.Colors.success,
                date: task.completedAt!
            ))
        }
        
        // 最近的财务记录
        let recentRecords = financialRecords
            .sorted { $0.date > $1.date }
            .prefix(3)
        
        for record in recentRecords {
            activities.append(Activity(
                id: record.id.uuidString,
                title: record.type == .income ? "收入记录" : "支出记录",
                subtitle: record.title,
                icon: record.type == .income ? "arrow.down.circle.fill" : "arrow.up.circle.fill",
                color: record.type == .income ? DesignSystem.Colors.success : DesignSystem.Colors.error,
                date: record.date
            ))
        }
        
        return activities.sorted { $0.date > $1.date }
    }
    
    // MARK: - 预算相关
    private func getCurrentSpending(for budget: Budget) -> Double {
        return financialRecords
            .filter { $0.type == .expense && $0.category == budget.category }
            .reduce(0) { $0 + $1.amount }
    }
}

// MARK: - 数据模型
struct TaskCompletionData: Identifiable {
    let id = UUID()
    let date: Date
    let completedCount: Int
}

struct FinancialData: Identifiable {
    let id = UUID()
    let date: Date
    let amount: Double
    let type: TransactionType
}

struct Activity: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let date: Date
}

// MARK: - 时间范围枚举
enum TimeRange: CaseIterable {
    case day, week, month, quarter, year
    
    var title: String {
        switch self {
        case .day: return "今天"
        case .week: return "本周"
        case .month: return "本月"
        case .quarter: return "本季度"
        case .year: return "本年"
        }
    }
}

// MARK: - 添加类型枚举
enum AddSheetType: CaseIterable {
    case task, financialRecord, password, virtualAsset
    
    var title: String {
        switch self {
        case .task: return "任务"
        case .financialRecord: return "财务记录"
        case .password: return "密码"
        case .virtualAsset: return "虚拟资产"
        }
    }
    
    var icon: String {
        switch self {
        case .task: return "checklist"
        case .financialRecord: return "dollarsign.circle"
        case .password: return "lock.shield"
        case .virtualAsset: return "creditcard"
        }
    }
}

// MARK: - 统计卡片
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        ModernCard {
            VStack(spacing: DesignSystem.Spacing.sm) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(value)
                    .font(DesignSystem.Typography.title3)
                    .fontWeight(.bold)
                    .foregroundColor(DesignSystem.Colors.text)
                
                Text(title)
                    .font(DesignSystem.Typography.caption1)
                    .foregroundColor(DesignSystem.Colors.secondaryText)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - 统计项目
struct StatItem: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(DesignSystem.Typography.title3)
                .fontWeight(.bold)
                .foregroundColor(DesignSystem.Colors.text)
            
            Text(label)
                .font(DesignSystem.Typography.caption1)
                .foregroundColor(DesignSystem.Colors.secondaryText)
        }
    }
}

// MARK: - 快速操作卡片
struct QuickActionCard: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        ModernCard {
            Button(action: action) {
                VStack(spacing: DesignSystem.Spacing.sm) {
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundColor(color)
                    
                    Text(title)
                        .font(DesignSystem.Typography.body)
                        .fontWeight(.medium)
                        .foregroundColor(DesignSystem.Colors.text)
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

// MARK: - 活动行
struct ActivityRow: View {
    let activity: Activity
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            Image(systemName: activity.icon)
                .font(.title3)
                .foregroundColor(activity.color)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                Text(activity.title)
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(DesignSystem.Colors.text)
                
                Text(activity.subtitle)
                    .font(DesignSystem.Typography.caption1)
                    .foregroundColor(DesignSystem.Colors.secondaryText)
            }
            
            Spacer()
            
            Text(activity.date.formatted(date: .abbreviated, time: .omitted))
                .font(DesignSystem.Typography.caption2)
                .foregroundColor(DesignSystem.Colors.secondaryText)
        }
    }
}

// MARK: - 圆形进度视图
struct CircularProgressView: View {
    let progress: Double
    let color: Color
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.2), lineWidth: 8)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(color, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 1), value: progress)
        }
        .frame(width: 60, height: 60)
    }
}

#Preview {
    DashboardView()
        .modelContainer(for: [WorkTask.self, FinancialRecord.self, Budget.self, PasswordEntry.self, VirtualAsset.self], inMemory: true)
} 