//
//  FinancialManagementView.swift
//  PersonalAffairsManagement
//
//  Created by 汤寿麟 on 2025/6/23.
//

import SwiftUI
import SwiftData
import Charts

struct FinancialManagementView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var financialRecords: [FinancialRecord]
    @Query private var budgets: [Budget]
    
    @State private var searchText = ""
    @State private var selectedTimeRange: TimeRange = .month
    @State private var selectedType: TransactionType? = nil
    @State private var selectedCategory: FinancialCategory? = nil
    @State private var showingAddRecord = false
    @State private var showingAddBudget = false
    @State private var showingChart = false
    
    private var filteredRecords: [FinancialRecord] {
        var filtered = financialRecords
        
        // 搜索过滤
        if !searchText.isEmpty {
            filtered = filtered.filter { record in
                record.description.localizedCaseInsensitiveContains(searchText) ||
                record.category.description.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // 时间范围过滤
        filtered = filtered.filter { record in
            selectedTimeRange.contains(date: record.date)
        }
        
        // 类型过滤
        if let selectedType = selectedType {
            filtered = filtered.filter { $0.type == selectedType }
        }
        
        // 分类过滤
        if let selectedCategory = selectedCategory {
            filtered = filtered.filter { $0.category == selectedCategory }
        }
        
        return filtered.sorted { $0.date > $1.date }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: DesignSystem.Spacing.lg) {
                    // 财务概览
                    financialOverview
                    
                    // 过滤和搜索
                    filterSection
                    
                    // 预算状态
                    budgetStatus
                    
                    // 图表分析
                    chartAnalysis
                    
                    // 财务记录列表
                    financialRecordsList
                }
                .padding(.horizontal, DesignSystem.Spacing.md)
            }
            .background(DesignSystem.Colors.groupedBackground)
            .navigationTitle("财务管理")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("添加记录") {
                            showingAddRecord = true
                        }
                        Button("添加预算") {
                            showingAddBudget = true
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(DesignSystem.Colors.primary)
                    }
                }
            }
            .sheet(isPresented: $showingAddRecord) {
                AddFinancialRecordView()
            }
            .sheet(isPresented: $showingAddBudget) {
                AddBudgetView()
            }
        }
    }
    
    // MARK: - 财务概览
    private var financialOverview: some View {
        ModernCard(shadow: DesignSystem.Shadows.medium) {
            VStack(spacing: DesignSystem.Spacing.lg) {
                HStack {
                    Text("财务概览")
                        .font(DesignSystem.Typography.headline)
                        .foregroundColor(DesignSystem.Colors.text)
                    
                    Spacer()
                    
                    Text(selectedTimeRange.title)
                        .font(DesignSystem.Typography.caption1)
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                        .padding(.horizontal, DesignSystem.Spacing.sm)
                        .padding(.vertical, DesignSystem.Spacing.xs)
                        .background(DesignSystem.Colors.secondaryBackground)
                        .cornerRadius(DesignSystem.CornerRadius.full)
                }
                
                HStack(spacing: DesignSystem.Spacing.xl) {
                    FinancialStatCard(
                        title: "收入",
                        amount: totalIncome,
                        icon: "arrow.up.circle.fill",
                        color: DesignSystem.Colors.success
                    )
                    
                    FinancialStatCard(
                        title: "支出",
                        amount: totalExpense,
                        icon: "arrow.down.circle.fill",
                        color: DesignSystem.Colors.error
                    )
                }
                
                ModernDivider()
                
                HStack {
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                        Text("净收入")
                            .font(DesignSystem.Typography.subheadline)
                            .foregroundColor(DesignSystem.Colors.secondaryText)
                        
                        Text("¥\(String(format: "%.2f", netIncome))")
                            .font(DesignSystem.Typography.numberLarge)
                            .fontWeight(.bold)
                            .foregroundColor(netIncome >= 0 ? DesignSystem.Colors.success : DesignSystem.Colors.error)
                    }
                    
                    Spacer()
                    
                    // 收支比例
                    VStack(alignment: .trailing, spacing: DesignSystem.Spacing.xs) {
                        Text("收支比")
                            .font(DesignSystem.Typography.caption1)
                            .foregroundColor(DesignSystem.Colors.secondaryText)
                        
                        Text("\(String(format: "%.1f", incomeExpenseRatio))")
                            .font(DesignSystem.Typography.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(DesignSystem.Colors.text)
                    }
                }
            }
        }
    }
    
    // MARK: - 过滤和搜索
    private var filterSection: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            ModernSearchBar(
                text: $searchText,
                placeholder: "搜索财务记录..."
            )
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DesignSystem.Spacing.sm) {
                    // 时间范围
                    ForEach(TimeRange.allCases, id: \.self) { range in
                        ModernTag(
                            title: range.title,
                            color: DesignSystem.Colors.primary,
                            isSelected: selectedTimeRange == range
                        ) {
                            selectedTimeRange = range
                        }
                    }
                    
                    // 类型过滤
                    ForEach(TransactionType.allCases, id: \.self) { type in
                        ModernTag(
                            title: type == .income ? "收入" : "支出",
                            color: type == .income ? DesignSystem.Colors.success : DesignSystem.Colors.error,
                            isSelected: selectedType == type
                        ) {
                            if selectedType == type {
                                selectedType = nil
                            } else {
                                selectedType = type
                            }
                        }
                    }
                    
                    // 分类过滤
                    ForEach(FinancialCategory.allCases, id: \.self) { category in
                        ModernTag(
                            title: category.description,
                            color: DesignSystem.Colors.primary,
                            isSelected: selectedCategory == category
                        ) {
                            if selectedCategory == category {
                                selectedCategory = nil
                            } else {
                                selectedCategory = category
                            }
                        }
                    }
                }
                .padding(.horizontal, DesignSystem.Spacing.md)
            }
        }
    }
    
    // MARK: - 预算状态
    private var budgetStatus: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            HStack {
                Text("预算状态")
                    .font(DesignSystem.Typography.headline)
                    .foregroundColor(DesignSystem.Colors.text)
                
                Spacer()
                
                Button("添加预算") {
                    showingAddBudget = true
                }
                .font(DesignSystem.Typography.caption1)
                .foregroundColor(DesignSystem.Colors.primary)
            }
            
            if budgets.isEmpty {
                ModernCard {
                    EmptyStateView(
                        icon: "chart.pie",
                        title: "暂无预算",
                        subtitle: "设置预算来跟踪支出情况",
                        actionTitle: "添加预算"
                    ) {
                        showingAddBudget = true
                    }
                }
            } else {
                LazyVStack(spacing: DesignSystem.Spacing.sm) {
                    ForEach(budgets) { budget in
                        BudgetProgressCard(
                            budget: budget,
                            currentSpending: getCurrentSpending(for: budget)
                        )
                    }
                }
            }
        }
    }
    
    // MARK: - 图表分析
    private var chartAnalysis: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            HStack {
                Text("支出分析")
                    .font(DesignSystem.Typography.headline)
                    .foregroundColor(DesignSystem.Colors.text)
                
                Spacer()
                
                Button("查看详情") {
                    showingChart = true
                }
                .font(DesignSystem.Typography.caption1)
                .foregroundColor(DesignSystem.Colors.primary)
            }
            
            ModernCard {
                if !expenseChartData.isEmpty {
                    Chart(expenseChartData) { data in
                        SectorMark(
                            angle: .value("金额", data.amount),
                            innerRadius: .ratio(0.6),
                            angularInset: 2
                        )
                        .foregroundStyle(by: .value("分类", data.category))
                        .cornerRadius(4)
                    }
                    .frame(height: 200)
                    .chartLegend(position: .bottom, alignment: .center)
                } else {
                    EmptyStateView(
                        icon: "chart.pie",
                        title: "暂无数据",
                        subtitle: "添加支出记录来查看分析图表"
                    )
                    .frame(height: 200)
                }
            }
        }
        .sheet(isPresented: $showingChart) {
            FinancialChartView(records: financialRecords, timeRange: selectedTimeRange)
        }
    }
    
    // MARK: - 财务记录列表
    private var financialRecordsList: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            HStack {
                Text("财务记录")
                    .font(DesignSystem.Typography.headline)
                    .foregroundColor(DesignSystem.Colors.text)
                
                Spacer()
                
                Text("\(filteredRecords.count) 条记录")
                    .font(DesignSystem.Typography.caption1)
                    .foregroundColor(DesignSystem.Colors.secondaryText)
            }
            
            if filteredRecords.isEmpty {
                ModernCard {
                    EmptyStateView(
                        icon: "dollarsign.circle",
                        title: searchText.isEmpty ? "暂无记录" : "未找到相关记录",
                        subtitle: searchText.isEmpty ? "开始记录你的第一笔收支吧" : "尝试调整搜索条件",
                        actionTitle: searchText.isEmpty ? "添加记录" : nil
                    ) {
                        if searchText.isEmpty {
                            showingAddRecord = true
                        }
                    }
                }
            } else {
                LazyVStack(spacing: DesignSystem.Spacing.sm) {
                    ForEach(filteredRecords) { record in
                        FinancialRecordRow(record: record)
                    }
                }
            }
        }
    }
    
    // MARK: - 计算属性
    private var totalIncome: Double {
        return filteredRecords
            .filter { $0.type == .income }
            .reduce(0) { $0 + $1.amount }
    }
    
    private var totalExpense: Double {
        return filteredRecords
            .filter { $0.type == .expense }
            .reduce(0) { $0 + $1.amount }
    }
    
    private var netIncome: Double {
        return totalIncome - totalExpense
    }
    
    private var incomeExpenseRatio: Double {
        guard totalExpense > 0 else { return 0 }
        return totalIncome / totalExpense
    }
    
    private var expenseChartData: [ExpenseChartData] {
        let expenseRecords = filteredRecords.filter { $0.type == .expense }
        let groupedByCategory = Dictionary(grouping: expenseRecords) { $0.category }
        
        return groupedByCategory.map { category, records in
            ExpenseChartData(
                category: category.description,
                amount: records.reduce(0) { $0 + $1.amount }
            )
        }.sorted { $0.amount > $1.amount }
    }
    
    private func getCurrentSpending(for budget: Budget) -> Double {
        return filteredRecords
            .filter { 
                $0.type == .expense &&
                $0.category == budget.category
            }
            .reduce(0) { $0 + $1.amount }
    }
}

// MARK: - 财务统计卡片
struct FinancialStatCard: View {
    let title: String
    let amount: Double
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title3)
                
                Text(title)
                    .font(DesignSystem.Typography.caption1)
                    .foregroundColor(DesignSystem.Colors.secondaryText)
            }
            
            Text("¥\(String(format: "%.2f", amount))")
                .font(DesignSystem.Typography.number)
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - 预算进度卡片
struct BudgetProgressCard: View {
    let budget: Budget
    let currentSpending: Double
    
    private var progress: Double {
        guard budget.amount > 0 else { return 0 }
        return min(currentSpending / budget.amount, 1.0)
    }
    
    private var progressColor: Color {
        if progress > 0.9 {
            return DesignSystem.Colors.error
        } else if progress > 0.7 {
            return DesignSystem.Colors.warning
        } else {
            return DesignSystem.Colors.success
        }
    }
    
    private var remainingAmount: Double {
        return max(budget.amount - currentSpending, 0)
    }
    
    var body: some View {
        ModernCard {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                HStack {
                    Text(budget.category.description)
                        .font(DesignSystem.Typography.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(DesignSystem.Colors.text)
                    
                    Spacer()
                    
                    Text("¥\(String(format: "%.0f", currentSpending)) / ¥\(String(format: "%.0f", budget.amount))")
                        .font(DesignSystem.Typography.caption1)
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                }
                
                ProgressView(value: progress)
                    .progressViewStyle(LinearProgressViewStyle(tint: progressColor))
                    .scaleEffect(y: 1.5)
                
                HStack {
                    Text("剩余: ¥\(String(format: "%.0f", remainingAmount))")
                        .font(DesignSystem.Typography.caption1)
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                    
                    Spacer()
                    
                    Text("\(String(format: "%.0f", progress * 100))%")
                        .font(DesignSystem.Typography.caption1)
                        .foregroundColor(progressColor)
                        .fontWeight(.medium)
                }
            }
        }
    }
}

// MARK: - 财务记录行
struct FinancialRecordRow: View {
    let record: FinancialRecord
    @State private var showingDetail = false
    @State private var isPressed = false
    
    var body: some View {
        ModernCard {
            Button(action: { showingDetail = true }) {
                HStack(spacing: DesignSystem.Spacing.md) {
                    // 类型图标
                    Image(systemName: record.type == .income ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                        .font(.title2)
                        .foregroundColor(record.type == .income ? DesignSystem.Colors.success : DesignSystem.Colors.error)
                    
                    // 记录内容
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                        Text(record.description)
                            .font(DesignSystem.Typography.body)
                            .fontWeight(.medium)
                            .foregroundColor(DesignSystem.Colors.text)
                            .lineLimit(1)
                        
                        HStack(spacing: DesignSystem.Spacing.sm) {
                            Text(record.category.description)
                                .font(DesignSystem.Typography.caption1)
                                .padding(.horizontal, DesignSystem.Spacing.xs)
                                .padding(.vertical, 2)
                                .background(DesignSystem.Colors.primary.opacity(0.1))
                                .foregroundColor(DesignSystem.Colors.primary)
                                .cornerRadius(DesignSystem.CornerRadius.xs)
                            
                            Text(record.date.formatted(date: .abbreviated, time: .omitted))
                                .font(DesignSystem.Typography.caption1)
                                .foregroundColor(DesignSystem.Colors.secondaryText)
                        }
                    }
                    
                    Spacer()
                    
                    // 金额
                    VStack(alignment: .trailing, spacing: DesignSystem.Spacing.xs) {
                        Text("¥\(String(format: "%.2f", record.amount))")
                            .font(DesignSystem.Typography.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(record.type == .income ? DesignSystem.Colors.success : DesignSystem.Colors.error)
                        
                        Text(record.type == .income ? "收入" : "支出")
                            .font(DesignSystem.Typography.caption2)
                            .foregroundColor(DesignSystem.Colors.secondaryText)
                    }
                    
                    // 详情按钮
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(DesignSystem.Animation.quick, value: isPressed)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
        .sheet(isPresented: $showingDetail) {
            FinancialRecordDetailView(record: record)
        }
    }
}

// MARK: - 财务记录详情视图
struct FinancialRecordDetailView: View {
    let record: FinancialRecord
    @Environment(\.dismiss) private var dismiss
    @State private var showingEdit = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: DesignSystem.Spacing.lg) {
                    // 记录标题
                    recordHeader
                    
                    // 记录详情
                    recordDetails
                    
                    // 备注信息
                    if let notes = record.notes, !notes.isEmpty {
                        Text(notes)
                            .font(DesignSystem.Typography.caption1)
                            .foregroundColor(DesignSystem.Colors.secondaryText)
                            .lineLimit(2)
                    }
                }
                .padding(DesignSystem.Spacing.md)
            }
            .background(DesignSystem.Colors.groupedBackground)
            .navigationTitle("记录详情")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("关闭") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("编辑") {
                        showingEdit = true
                    }
                }
            }
            .sheet(isPresented: $showingEdit) {
                // EditFinancialRecordView(record: record)
                Text("编辑功能待实现")
            }
        }
    }
    
    private var recordHeader: some View {
        ModernCard {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                HStack {
                    Image(systemName: record.type == .income ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                        .font(.title)
                        .foregroundColor(record.type == .income ? DesignSystem.Colors.success : DesignSystem.Colors.error)
                    
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                        Text(record.description)
                            .font(DesignSystem.Typography.title3)
                            .fontWeight(.bold)
                            .foregroundColor(DesignSystem.Colors.text)
                        
                        Text(record.category.description)
                            .font(DesignSystem.Typography.caption1)
                            .padding(.horizontal, DesignSystem.Spacing.sm)
                            .padding(.vertical, 4)
                            .background(DesignSystem.Colors.primary.opacity(0.1))
                            .foregroundColor(DesignSystem.Colors.primary)
                            .cornerRadius(DesignSystem.CornerRadius.sm)
                    }
                    
                    Spacer()
                    
                    Text("¥\(String(format: "%.2f", record.amount))")
                        .font(DesignSystem.Typography.numberLarge)
                        .fontWeight(.bold)
                        .foregroundColor(record.type == .income ? DesignSystem.Colors.success : DesignSystem.Colors.error)
                }
            }
        }
    }
    
    private var recordDetails: some View {
        ModernCard {
            VStack(spacing: DesignSystem.Spacing.md) {
                InfoRow(
                    title: "类型",
                    value: record.type == .income ? "收入" : "支出",
                    icon: record.type == .income ? "arrow.up.circle" : "arrow.down.circle"
                )
                
                InfoRow(
                    title: "分类",
                    value: record.category.description,
                    icon: "tag"
                )
                
                InfoRow(
                    title: "日期",
                    value: record.date.formatted(date: .complete, time: .shortened),
                    icon: "calendar"
                )
                
                if let location = record.location {
                    InfoRow(
                        title: "位置",
                        value: location,
                        icon: "location"
                    )
                }
            }
        }
    }
}

// MARK: - 财务图表视图
struct FinancialChartView: View {
    let records: [FinancialRecord]
    let timeRange: TimeRange
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: DesignSystem.Spacing.lg) {
                    // 支出分类饼图
                    expenseCategoryChart
                    
                    // 收支趋势图
                    incomeExpenseTrendChart
                    
                    // 分类统计
                    categoryStatistics
                }
                .padding(DesignSystem.Spacing.md)
            }
            .background(DesignSystem.Colors.groupedBackground)
            .navigationTitle("财务分析")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var expenseCategoryChart: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("支出分类")
                .font(DesignSystem.Typography.headline)
                .foregroundColor(DesignSystem.Colors.text)
            
            ModernCard {
                if !expenseChartData.isEmpty {
                    Chart(expenseChartData) { data in
                        SectorMark(
                            angle: .value("金额", data.amount),
                            innerRadius: .ratio(0.6),
                            angularInset: 2
                        )
                        .foregroundStyle(by: .value("分类", data.category))
                        .cornerRadius(4)
                    }
                    .frame(height: 250)
                    .chartLegend(position: .bottom, alignment: .center)
                } else {
                    EmptyStateView(
                        icon: "chart.pie",
                        title: "暂无数据",
                        subtitle: "添加支出记录来查看分析图表"
                    )
                    .frame(height: 250)
                }
            }
        }
    }
    
    private var incomeExpenseTrendChart: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("收支趋势")
                .font(DesignSystem.Typography.headline)
                .foregroundColor(DesignSystem.Colors.text)
            
            ModernCard {
                if !trendChartData.isEmpty {
                    Chart(trendChartData) { data in
                        LineMark(
                            x: .value("日期", data.date),
                            y: .value("金额", data.amount)
                        )
                        .foregroundStyle(by: .value("类型", data.type))
                        .lineStyle(StrokeStyle(lineWidth: 3))
                        
                        AreaMark(
                            x: .value("日期", data.date),
                            y: .value("金额", data.amount)
                        )
                        .foregroundStyle(by: .value("类型", data.type))
                        .opacity(0.1)
                    }
                    .frame(height: 200)
                    .chartForegroundStyleScale([
                        "收入": DesignSystem.Colors.success,
                        "支出": DesignSystem.Colors.error
                    ])
                    .chartXAxis {
                        AxisMarks(values: .stride(by: .day)) { value in
                            AxisGridLine()
                            AxisValueLabel(format: .dateTime.day())
                        }
                    }
                } else {
                    EmptyStateView(
                        icon: "chart.line.uptrend.xyaxis",
                        title: "暂无数据",
                        subtitle: "添加财务记录来查看趋势图表"
                    )
                    .frame(height: 200)
                }
            }
        }
    }
    
    private var categoryStatistics: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("分类统计")
                .font(DesignSystem.Typography.headline)
                .foregroundColor(DesignSystem.Colors.text)
            
            LazyVStack(spacing: DesignSystem.Spacing.sm) {
                ForEach(categoryStats, id: \.category) { stat in
                    CategoryStatRow(stat: stat)
                }
            }
        }
    }
    
    // MARK: - 计算属性
    private var expenseChartData: [ExpenseChartData] {
        let expenseRecords = records.filter { 
            $0.type == .expense && timeRange.contains(date: $0.date)
        }
        let groupedByCategory = Dictionary(grouping: expenseRecords) { $0.category }
        
        return groupedByCategory.map { category, records in
            ExpenseChartData(
                category: category.description,
                amount: records.reduce(0) { $0 + $1.amount }
            )
        }.sorted { $0.amount > $1.amount }
    }
    
    private var trendChartData: [TrendChartData] {
        let calendar = Calendar.current
        let endDate = Date()
        let startDate = calendar.date(byAdding: .day, value: -6, to: endDate) ?? endDate
        
        var dates: [Date] = []
        var currentDate = startDate
        
        while currentDate <= endDate {
            dates.append(currentDate)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }
        
        return dates.flatMap { date in
            let incomeAmount = records.filter { 
                $0.type == .income && calendar.isDate($0.date, inSameDayAs: date)
            }.reduce(0) { $0 + $1.amount }
            
            let expenseAmount = records.filter { 
                $0.type == .expense && calendar.isDate($0.date, inSameDayAs: date)
            }.reduce(0) { $0 + $1.amount }
            
            return [
                TrendChartData(date: date, amount: incomeAmount, type: "收入"),
                TrendChartData(date: date, amount: expenseAmount, type: "支出")
            ]
        }
    }
    
    private var categoryStats: [CategoryStat] {
        let groupedByCategory = Dictionary(grouping: records.filter { timeRange.contains(date: $0.date) }) { $0.category }
        
        return groupedByCategory.map { category, records in
            let income = records.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
            let expense = records.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
            
            return CategoryStat(
                category: category.description,
                income: income,
                expense: expense,
                net: income - expense
            )
        }.sorted { $0.expense > $1.expense }
    }
}

// MARK: - 分类统计行
struct CategoryStatRow: View {
    let stat: CategoryStat
    
    var body: some View {
        ModernCard {
            HStack {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    Text(stat.category)
                        .font(DesignSystem.Typography.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(DesignSystem.Colors.text)
                    
                    HStack(spacing: DesignSystem.Spacing.sm) {
                        Text("收入: ¥\(String(format: "%.0f", stat.income))")
                            .font(DesignSystem.Typography.caption1)
                            .foregroundColor(DesignSystem.Colors.success)
                        
                        Text("支出: ¥\(String(format: "%.0f", stat.expense))")
                            .font(DesignSystem.Typography.caption1)
                            .foregroundColor(DesignSystem.Colors.error)
                    }
                }
                
                Spacer()
                
                Text("¥\(String(format: "%.0f", stat.net))")
                    .font(DesignSystem.Typography.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(stat.net >= 0 ? DesignSystem.Colors.success : DesignSystem.Colors.error)
            }
        }
    }
}

// MARK: - 数据模型
struct ExpenseChartData: Identifiable {
    let id = UUID()
    let category: String
    let amount: Double
}

struct TrendChartData: Identifiable {
    let id = UUID()
    let date: Date
    let amount: Double
    let type: String
}

struct CategoryStat {
    let category: String
    let income: Double
    let expense: Double
    let net: Double
}

// MARK: - 时间范围扩展
extension TimeRange {
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
        case .quarter:
            return calendar.isDate(date, equalTo: now, toGranularity: .quarter)
        case .year:
            return calendar.isDate(date, equalTo: now, toGranularity: .year)
        }
    }
}

#Preview {
    FinancialManagementView()
        .modelContainer(for: [FinancialRecord.self, Budget.self], inMemory: true)
} 