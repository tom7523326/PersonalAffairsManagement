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
    @StateObject private var dataManager = DataQueryManager()
    @State private var selectedTimeRange: TimeRange = .month
    @State private var showingAddSheet = false
    @State private var addSheetType: AddSheetType? = nil
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: DesignSystem.Spacing.lg) {
                    // 快速统计网格
                    QuickStatsGrid(dataManager: dataManager)
                    
                    // 任务完成情况图表
                    TaskCompletionChart(tasks: dataManager.tasks, timeRange: selectedTimeRange)
                    
                    // 财务概览部分
                    FinancialOverviewSection(dataManager: dataManager)
                }
                .padding()
            }
            .navigationTitle("仪表板")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("添加任务") { 
                            addSheetType = .task
                            showingAddSheet = true
                        }
                        Button("添加财务记录") { 
                            addSheetType = .financialRecord
                            showingAddSheet = true
                        }
                        Button("添加密码") { 
                            addSheetType = .password
                            showingAddSheet = true
                        }
                        Button("添加虚拟资产") { 
                            addSheetType = .virtualAsset
                            showingAddSheet = true
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(DesignSystem.Colors.primary)
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            if let type = addSheetType {
                AddItemSheet(type: type)
            }
        }
        .onAppear {
            dataManager.setModelContext(modelContext)
        }
    }
}

// MARK: - 快速统计网格
struct QuickStatsGrid: View {
    let dataManager: DataQueryManager
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: DesignSystem.Spacing.md) {
            StatCard(
                title: "待办任务",
                value: "\(dataManager.tasks.filter { $0.project == nil }.count)",
                icon: "checklist",
                color: .blue
            )
            
            StatCard(
                title: "本月支出",
                value: "¥\(String(format: "%.0f", dataManager.records.filter { $0.type == .expense && Calendar.current.isDate($0.date, equalTo: Date(), toGranularity: .month) }.reduce(0) { $0 + $1.amount }))",
                icon: "creditcard",
                color: .red
            )
            
            StatCard(
                title: "密码数量",
                value: "\(dataManager.passwords.count)",
                icon: "lock.shield",
                color: .purple
            )
            
            StatCard(
                title: "虚拟资产",
                value: "¥\(String(format: "%.0f", dataManager.assets.reduce(0) { $0 + $1.value }))",
                icon: "gift",
                color: .orange
            )
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
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
                
                Text(value)
                    .font(DesignSystem.Typography.title2)
                    .fontWeight(.bold)
                    .foregroundColor(DesignSystem.Colors.text)
                
                Text(title)
                    .font(DesignSystem.Typography.footnote)
                    .foregroundColor(DesignSystem.Colors.secondaryText)
            }
        }
    }
}

// MARK: - 任务完成情况图表
struct TaskCompletionChart: View {
    let tasks: [WorkTask]
    let timeRange: TimeRange

    struct TaskStats: Identifiable {
        let id = UUID()
        let date: Date
        let count: Int
        let status: TaskStatus
    }
    
    var data: [TaskStats] {
        let calendar = Calendar.current
        let filteredTasks = tasks.filter { task in
            guard let date = task.dueDate else { return false }
            return timeRange.contains(date: date)
        }
        
        let groupedByDateAndStatus = Dictionary(grouping: filteredTasks) { task -> Date in
            return calendar.startOfDay(for: task.dueDate!)
        }.mapValues { tasksOnDate -> [TaskStatus: Int] in
            return Dictionary(grouping: tasksOnDate, by: { $0.status }).mapValues { $0.count }
        }

        var stats: [TaskStats] = []
        for (date, statusCounts) in groupedByDateAndStatus {
            for (status, count) in statusCounts {
                stats.append(TaskStats(date: date, count: count, status: status))
            }
        }
        return stats.sorted(by: { $0.date < $1.date })
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text("任务完成趋势")
                 .font(DesignSystem.Typography.subheadline)
                 .foregroundColor(DesignSystem.Colors.secondaryText)
            
            if data.isEmpty {
                ContentUnavailableView("无数据显示", systemImage: "chart.bar.xaxis", description: Text("在所选时间范围内没有任务数据。"))
                    .frame(height: 150)
            } else {
                Chart(data) { stat in
                    BarMark(
                        x: .value("日期", stat.date, unit: .day),
                        y: .value("数量", stat.count)
                    )
                    .foregroundStyle(by: .value("状态", stat.status.rawValue))
                }
                .chartForegroundStyleScale([
                    TaskStatus.pending.rawValue: Color.gray,
                    TaskStatus.inProgress.rawValue: Color.blue,
                    TaskStatus.completed.rawValue: Color.green,
                    TaskStatus.cancelled.rawValue: Color.red
                ])
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day)) { _ in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel(format: .dateTime.month().day())
                    }
                }
                .frame(height: 150)
            }
        }
    }
}

// MARK: - 财务概览部分
struct FinancialOverviewSection: View {
    let dataManager: DataQueryManager
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            FinancialSummaryCard(records: dataManager.records)
            BudgetStatusView(records: dataManager.records, budgets: dataManager.budgets)
        }
        .padding()
        .background(DesignSystem.Colors.cardBackground)
        .cornerRadius(DesignSystem.CornerRadius.md)
    }
}

// MARK: - 财务摘要卡片
struct FinancialSummaryCard: View {
    let records: [FinancialRecord]
    
    var body: some View {
        VStack {
            HStack {
                FinancialStatView(title: "总收入", amount: totalIncome, color: .green)
                Spacer()
                FinancialStatView(title: "总支出", amount: totalExpense, color: .red)
                Spacer()
                FinancialStatView(title: "净收入", amount: netIncome, color: DesignSystem.Colors.text)
            }
        }
    }
    
    private var totalIncome: Double {
        records.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
    }
    
    private var totalExpense: Double {
        records.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
    }
    
    private var netIncome: Double {
        totalIncome - totalExpense
    }
}

// MARK: - 单个财务统计
struct FinancialStatView: View {
    let title: String
    let amount: Double
    let color: Color

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(DesignSystem.Typography.caption1)
                .foregroundColor(DesignSystem.Colors.secondaryText)
            Text("¥\(amount, specifier: "%.0f")")
                .font(DesignSystem.Typography.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
    }
}

// MARK: - 预算状态视图
struct BudgetStatusView: View {
    let records: [FinancialRecord]
    let budgets: [Budget]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("预算概览")
                .font(DesignSystem.Typography.subheadline)
                .foregroundColor(DesignSystem.Colors.secondaryText)
            
            if budgets.isEmpty {
                Text("未设置预算。")
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(DesignSystem.Colors.secondaryText)
            } else {
                ForEach(budgets) { budget in
                    BudgetProgressView(budget: budget, currentSpending: spending(for: budget.category))
                }
            }
        }
    }
    
    private func spending(for category: FinancialCategory) -> Double {
        let calendar = Calendar.current
        let now = Date()
        let budgetCycleStart: Date
        
        // This logic assumes budgets reset monthly. Could be adapted for different cycles.
        let components = calendar.dateComponents([.year, .month], from: now)
        budgetCycleStart = calendar.date(from: components)!

        return records.filter {
            $0.category == category &&
            $0.type == .expense &&
            $0.date >= budgetCycleStart
        }.reduce(0) { $0 + $1.amount }
    }
}

// MARK: - 预算进度条
struct BudgetProgressView: View {
    let budget: Budget
    let currentSpending: Double
    
    private var progress: Double {
        guard budget.amount > 0 else { return 0 }
        return min(currentSpending / budget.amount, 1.0) // Cap at 100%
    }
    
    private var progressColor: Color {
        if progress > 0.9 {
            return .red
        } else if progress > 0.7 {
            return .orange
        } else {
            return .green
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
            HStack {
                Text(budget.category.description)
                Spacer()
                Text("¥\(currentSpending, specifier: "%.0f") / ¥\(budget.amount, specifier: "%.0f")")
                    .font(DesignSystem.Typography.caption1)
                    .foregroundColor(DesignSystem.Colors.secondaryText)
            }
            
            ProgressView(value: progress)
                .progressViewStyle(LinearProgressViewStyle(tint: progressColor))
        }
    }
}

// MARK: - 辅助类型
enum TimeRange: CaseIterable {
    case day, week, month, year
    
    var title: String {
        switch self {
        case .day: return "日"
        case .week: return "周"
        case .month: return "月"
        case .year: return "年"
        }
    }
    
    func contains(date: Date) -> Bool {
        let calendar = Calendar.current
        let now = Date()
        switch self {
        case .day:
            return calendar.isDateInToday(date)
        case .week:
            return calendar.isDate(date, equalTo: now, toGranularity: .weekOfYear)
        case .month:
            return calendar.isDate(date, equalTo: now, toGranularity: .month)
        case .year:
            return calendar.isDate(date, equalTo: now, toGranularity: .year)
        }
    }
}

struct ChartData: Identifiable {
    let id = UUID()
    let date: Date
    let completedCount: Int
}

struct ActivityItem {
    let id: String
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
}

#Preview {
    DashboardView()
        .modelContainer(for: [WorkTask.self, FinancialRecord.self, Budget.self, PasswordEntry.self, VirtualAsset.self], inMemory: true)
} 