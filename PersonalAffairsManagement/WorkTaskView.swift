//
//  WorkTaskView.swift
//  PersonalAffairsManagement
//
//  Created by 汤寿麟 on 2025/6/23.
//

import SwiftUI
import SwiftData

struct WorkTaskView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \WorkTask.createdAt, order: .reverse) private var tasks: [WorkTask]
    @Query(sort: \Project.createdAt, order: .reverse) private var projects: [Project]
    
    @State private var searchText = ""
    @State private var selectedFilter: TaskFilter = .all
    @State private var selectedSortOption: TaskSortOption = .dueDate
    @State private var showingAddTask = false
    @State private var showingProjectFilter = false
    @State private var selectedProject: Project? = nil
    
    private var filteredTasks: [WorkTask] {
        var filtered = tasks
        
        // 搜索过滤
        if !searchText.isEmpty {
            filtered = filtered.filter { task in
                task.title.localizedCaseInsensitiveContains(searchText) ||
                task.taskDescription.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // 状态过滤
        switch selectedFilter {
        case .all:
            break
        case .pending:
            filtered = filtered.filter { $0.status == .pending }
        case .inProgress:
            filtered = filtered.filter { $0.status == .inProgress }
        case .completed:
            filtered = filtered.filter { $0.status == .completed }
        case .overdue:
            filtered = filtered.filter { task in
                task.status == .pending && 
                task.dueDate != nil && 
                task.dueDate! < Date()
            }
        }
        
        // 项目过滤
        if let selectedProject = selectedProject {
            filtered = filtered.filter { $0.project?.id == selectedProject.id }
        }
        
        // 排序
        filtered.sort { first, second in
            switch selectedSortOption {
            case .dueDate:
                let firstDate = first.dueDate ?? Date.distantFuture
                let secondDate = second.dueDate ?? Date.distantFuture
                return firstDate < secondDate
            case .priority:
                return first.priority.rawValue > second.priority.rawValue
            case .createdDate:
                return first.createdAt > second.createdAt
            case .title:
                return first.title < second.title
            }
        }
        
        return filtered
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 搜索和过滤栏
                searchAndFilterBar
                
                // 任务统计
                taskStatistics
                
                // 任务列表
                taskList
            }
            .background(DesignSystem.Colors.groupedBackground)
            .navigationTitle("任务管理")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddTask = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(DesignSystem.Colors.primary)
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("测试") {
                        createTestTask()
                    }
                }
            }
            .sheet(isPresented: $showingAddTask) {
                AddTaskView()
            }
            .onAppear {
                print("[WorkTaskView] 视图已加载")
                print("[WorkTaskView] 当前任务数量: \(tasks.count)")
                print("[WorkTaskView] 当前项目数量: \(projects.count)")
                print("[WorkTaskView] ModelContext: \(modelContext)")
                
                // 测试数据库读取
                do {
                    let fetchDescriptor = FetchDescriptor<WorkTask>()
                    let allTasks = try modelContext.fetch(fetchDescriptor)
                    print("[WorkTaskView] 数据库查询结果: \(allTasks.count) 个任务")
                    
                    for (index, task) in allTasks.enumerated() {
                        print("[WorkTaskView] 任务 \(index + 1): \(task.title) (ID: \(task.id))")
                    }
                } catch {
                    print("[WorkTaskView] 数据库查询失败: \(error)")
                }
            }
        }
    }
    
    // MARK: - 搜索和过滤栏
    private var searchAndFilterBar: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            ModernSearchBar(
                text: $searchText,
                placeholder: "搜索任务..."
            )
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DesignSystem.Spacing.sm) {
                    // 状态过滤
                    ForEach(TaskFilter.allCases, id: \.self) { filter in
                        ModernTag(
                            title: filter.title,
                            color: filter.color,
                            isSelected: selectedFilter == filter
                        ) {
                            selectedFilter = filter
                        }
                    }
                    
                    // 项目过滤
                    if !projects.isEmpty {
                        ModernTag(
                            title: selectedProject?.name ?? "全部项目",
                            color: DesignSystem.Colors.project,
                            isSelected: selectedProject != nil
                        ) {
                            showingProjectFilter = true
                        }
                    }
                    
                    // 排序选项
                    Menu {
                        ForEach(TaskSortOption.allCases, id: \.self) { option in
                            Button(option.title) {
                                selectedSortOption = option
                            }
                        }
                    } label: {
                        HStack(spacing: DesignSystem.Spacing.xs) {
                            Text("排序")
                                .font(DesignSystem.Typography.caption1)
                            Image(systemName: "chevron.down")
                                .font(.caption)
                        }
                        .padding(.horizontal, DesignSystem.Spacing.sm)
                        .padding(.vertical, DesignSystem.Spacing.xs)
                        .background(DesignSystem.Colors.secondaryBackground)
                        .cornerRadius(DesignSystem.CornerRadius.full)
                    }
                }
                .padding(.horizontal, DesignSystem.Spacing.md)
            }
        }
        .padding(.vertical, DesignSystem.Spacing.md)
        .background(DesignSystem.Colors.background)
    }
    
    // MARK: - 任务统计
    private var taskStatistics: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DesignSystem.Spacing.md) {
                StatCard(
                    title: "总任务",
                    value: "\(tasks.count)",
                    icon: "checklist",
                    color: DesignSystem.Colors.task
                )
                
                StatCard(
                    title: "待处理",
                    value: "\(tasks.filter { $0.status == .pending }.count)",
                    icon: "clock",
                    color: DesignSystem.Colors.warning
                )
                
                StatCard(
                    title: "进行中",
                    value: "\(tasks.filter { $0.status == .inProgress }.count)",
                    icon: "play.circle",
                    color: DesignSystem.Colors.primary
                )
                
                StatCard(
                    title: "已完成",
                    value: "\(tasks.filter { $0.status == .completed }.count)",
                    icon: "checkmark.circle",
                    color: DesignSystem.Colors.success
                )
                
                StatCard(
                    title: "已逾期",
                    value: "\(overdueTasksCount)",
                    icon: "exclamationmark.triangle",
                    color: DesignSystem.Colors.error
                )
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
        }
        .padding(.vertical, DesignSystem.Spacing.sm)
    }
    
    // MARK: - 任务列表
    private var taskList: some View {
        Group {
            if filteredTasks.isEmpty {
                EmptyStateView(
                    icon: "checklist",
                    title: searchText.isEmpty ? "暂无任务" : "未找到相关任务",
                    subtitle: searchText.isEmpty ? "开始创建你的第一个任务吧" : "尝试调整搜索条件",
                    actionTitle: searchText.isEmpty ? "添加任务" : nil
                ) {
                    if searchText.isEmpty {
                        showingAddTask = true
                    }
                }
            } else {
                LazyVStack(spacing: DesignSystem.Spacing.sm) {
                    ForEach(filteredTasks) { task in
                        TaskRowView(task: task) {
                            // 任务完成状态切换
                            task.status = task.status == .completed ? .pending : .completed
                            if task.status == .completed {
                                task.completedAt = Date()
                            } else {
                                task.completedAt = nil
                            }
                        }
                    }
                }
                .padding(.horizontal, DesignSystem.Spacing.md)
            }
        }
    }
    
    // MARK: - 计算属性
    private var overdueTasksCount: Int {
        return tasks.filter { task in
            task.status == .pending && 
            task.dueDate != nil && 
            task.dueDate! < Date()
        }.count
    }
    
    // MARK: - 测试方法
    private func createTestTask() {
        print("[WorkTaskView] 开始创建测试任务")
        
        let testTask = WorkTask(
            title: "测试任务 \(Date().formatted(date: .omitted, time: .shortened))",
            taskDescription: "这是一个测试任务",
            priority: .medium,
            dueDate: Date().addingTimeInterval(86400), // 明天
            project: projects.first
        )
        
        print("[WorkTaskView] 测试任务对象创建: \(testTask.title)")
        print("[WorkTaskView] 测试任务ID: \(testTask.id)")
        
        modelContext.insert(testTask)
        print("[WorkTaskView] 测试任务已插入到ModelContext")
        
        do {
            try modelContext.save()
            print("[WorkTaskView] 测试任务保存成功")
        } catch {
            print("[WorkTaskView] 测试任务保存失败: \(error)")
        }
    }
}

// MARK: - 任务行视图
struct TaskRowView: View {
    let task: WorkTask
    let onToggleStatus: () -> Void
    
    @State private var showingDetail = false
    @State private var isPressed = false
    
    private var isOverdue: Bool {
        guard let dueDate = task.dueDate else { return false }
        return task.status == .pending && dueDate < Date()
    }
    
    private var daysUntilDue: Int? {
        guard let dueDate = task.dueDate else { return nil }
        let calendar = Calendar.current
        return calendar.dateComponents([.day], from: Date(), to: dueDate).day
    }
    
    var body: some View {
        ModernCard {
            HStack(spacing: DesignSystem.Spacing.md) {
                // 完成状态按钮
                Button(action: onToggleStatus) {
                    Image(systemName: task.status == .completed ? "checkmark.circle.fill" : "circle")
                        .font(.title2)
                        .foregroundColor(task.status == .completed ? DesignSystem.Colors.success : DesignSystem.Colors.secondaryText)
                }
                .buttonStyle(PlainButtonStyle())
                
                // 任务内容
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    HStack {
                        Text(task.title)
                            .font(DesignSystem.Typography.body)
                            .fontWeight(.medium)
                            .strikethrough(task.status == .completed)
                            .foregroundColor(task.status == .completed ? DesignSystem.Colors.secondaryText : DesignSystem.Colors.text)
                            .lineLimit(1)
                        
                        Spacer()
                        
                        // 优先级标签
                        PriorityBadge(priority: task.priority)
                    }
                    
                    if !task.taskDescription.isEmpty {
                        Text(task.taskDescription)
                            .font(DesignSystem.Typography.caption1)
                            .foregroundColor(DesignSystem.Colors.secondaryText)
                            .lineLimit(2)
                    }
                    
                    // 任务元数据
                    HStack(spacing: DesignSystem.Spacing.sm) {
                        // 项目标签
                        if let project = task.project {
                            HStack(spacing: DesignSystem.Spacing.xs) {
                                Circle()
                                    .fill(Color(hex: project.colorHex) ?? DesignSystem.Colors.project)
                                    .frame(width: 8, height: 8)
                                Text(project.name)
                                    .font(DesignSystem.Typography.caption2)
                                    .foregroundColor(DesignSystem.Colors.secondaryText)
                            }
                        }
                        
                        // 截止日期
                        if let dueDate = task.dueDate {
                            HStack(spacing: DesignSystem.Spacing.xs) {
                                Image(systemName: "calendar")
                                    .font(.caption2)
                                    .foregroundColor(isOverdue ? DesignSystem.Colors.error : DesignSystem.Colors.secondaryText)
                                
                                Text(dueDate.formatted(date: .abbreviated, time: .omitted))
                                    .font(DesignSystem.Typography.caption2)
                                    .foregroundColor(isOverdue ? DesignSystem.Colors.error : DesignSystem.Colors.secondaryText)
                                
                                if let days = daysUntilDue {
                                    Text("(\(days > 0 ? "+" : "")\(days)天)")
                                        .font(DesignSystem.Typography.caption2)
                                        .foregroundColor(isOverdue ? DesignSystem.Colors.error : DesignSystem.Colors.secondaryText)
                                }
                            }
                        }
                        
                        Spacer()
                        
                        // 创建时间
                        Text(task.createdAt.formatted(date: .abbreviated, time: .omitted))
                            .font(DesignSystem.Typography.caption2)
                            .foregroundColor(DesignSystem.Colors.secondaryText)
                    }
                }
                
                // 更多操作按钮
                Button(action: { showingDetail = true }) {
                    Image(systemName: "ellipsis.circle")
                        .font(.title3)
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(DesignSystem.Spacing.md)
        }
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = false
                }
            }
        }
        .sheet(isPresented: $showingDetail) {
            TaskDetailView(task: task)
        }
    }
}

// MARK: - 任务详情视图
struct TaskDetailView: View {
    let task: WorkTask
    @Environment(\.dismiss) private var dismiss
    @State private var showingEdit = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: DesignSystem.Spacing.lg) {
                    // 任务标题和状态
                    taskHeader
                    
                    // 任务描述
                    if !task.taskDescription.isEmpty {
                        taskDescription
                    }
                    
                    // 任务详情
                    taskDetails
                    
                    // 项目信息
                    if let project = task.project {
                        projectInfo(project)
                    }
                }
                .padding(DesignSystem.Spacing.md)
            }
            .background(DesignSystem.Colors.groupedBackground)
            .navigationTitle("任务详情")
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
                EditTaskView(task: task)
            }
        }
    }
    
    private var taskHeader: some View {
        ModernCard {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                HStack {
                    Text(task.title)
                        .font(DesignSystem.Typography.title2)
                        .fontWeight(.bold)
                        .foregroundColor(DesignSystem.Colors.text)
                    
                    Spacer()
                    
                    PriorityBadge(priority: task.priority)
                }
                
                HStack {
                    StatusBadge(status: task.status)
                    Spacer()
                }
            }
        }
    }
    
    private var taskDescription: some View {
        ModernCard {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                Text("描述")
                    .font(DesignSystem.Typography.headline)
                    .foregroundColor(DesignSystem.Colors.text)
                
                Text(task.taskDescription)
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(DesignSystem.Colors.text)
            }
        }
    }
    
    private var taskDetails: some View {
        ModernCard {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                Text("任务详情")
                    .font(DesignSystem.Typography.headline)
                    .foregroundColor(DesignSystem.Colors.text)
                
                VStack(spacing: DesignSystem.Spacing.sm) {
                    DetailRow(title: "创建时间", value: task.createdAt.formatted(date: .abbreviated, time: .shortened))
                    
                    if let dueDate = task.dueDate {
                        DetailRow(title: "截止时间", value: dueDate.formatted(date: .abbreviated, time: .shortened))
                    }
                    
                    if let completedAt = task.completedAt {
                        DetailRow(title: "完成时间", value: completedAt.formatted(date: .abbreviated, time: .shortened))
                    }
                }
            }
        }
    }
    
    private func projectInfo(_ project: Project) -> some View {
        ModernCard {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                Text("所属项目")
                    .font(DesignSystem.Typography.headline)
                    .foregroundColor(DesignSystem.Colors.text)
                
                HStack {
                    Circle()
                        .fill(Color(hex: project.colorHex) ?? DesignSystem.Colors.project)
                        .frame(width: 12, height: 12)
                    
                    Text(project.name)
                        .font(DesignSystem.Typography.body)
                        .foregroundColor(DesignSystem.Colors.text)
                    
                    Spacer()
                }
            }
        }
    }
}

// MARK: - 任务过滤选项
enum TaskFilter: CaseIterable {
    case all, pending, inProgress, completed, overdue
    
    var title: String {
        switch self {
        case .all: return "全部"
        case .pending: return "待处理"
        case .inProgress: return "进行中"
        case .completed: return "已完成"
        case .overdue: return "已逾期"
        }
    }
    
    var color: Color {
        switch self {
        case .all: return DesignSystem.Colors.primary
        case .pending: return DesignSystem.Colors.warning
        case .inProgress: return DesignSystem.Colors.primary
        case .completed: return DesignSystem.Colors.success
        case .overdue: return DesignSystem.Colors.error
        }
    }
}

// MARK: - 任务排序选项
enum TaskSortOption: CaseIterable {
    case dueDate, priority, createdDate, title
    
    var title: String {
        switch self {
        case .dueDate: return "按截止时间"
        case .priority: return "按优先级"
        case .createdDate: return "按创建时间"
        case .title: return "按标题"
        }
    }
}

// MARK: - PriorityBadge
struct PriorityBadge: View {
    let priority: TaskPriority
    var body: some View {
        Text(priority.rawValue)
            .font(.caption2)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(priority.color.opacity(0.15))
            .foregroundColor(priority.color)
            .cornerRadius(8)
    }
}

// MARK: - StatusBadge
struct StatusBadge: View {
    let status: TaskStatus
    var body: some View {
        Text(status.description)
            .font(.caption2)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(Color.gray.opacity(0.15))
            .foregroundColor(.gray)
            .cornerRadius(8)
    }
}

// MARK: - DetailRow
struct DetailRow: View {
    let title: String
    let value: String
    var body: some View {
        HStack {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.caption)
                .foregroundColor(.primary)
        }
    }
}

#Preview {
    WorkTaskView()
        .modelContainer(for: [WorkTask.self, Project.self], inMemory: true)
} 