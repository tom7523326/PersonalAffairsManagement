import SwiftUI
import SwiftData

struct AppRootView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var cloudService: CloudService
    @State private var isAuthenticated = false
    @State private var isLoading = true
    @State private var selectedSidebarItem: SidebarItem? = .dashboard
    @State private var showQuickActions = false
    
    var body: some View {
        Group {
            if isLoading {
                LoadingView(message: "正在加载...")
            } else if !isAuthenticated {
                AuthenticationView()
            } else {
                mainInterface
            }
        }
        .onAppear {
            checkAuthenticationStatus()
        }
    }
    
    private var mainInterface: some View {
        NavigationSplitView {
            sidebar
        } detail: {
            detailView
        }
        .navigationSplitViewStyle(.balanced)
        .preferredColorScheme(themeManager.isDarkMode ? .dark : .light)
    }
    
    // MARK: - 侧边栏
    private var sidebar: some View {
        List(selection: $selectedSidebarItem) {
            // 快捷操作区域
            Section {
                quickActionsSection
            } header: {
                Text("快捷操作")
            }
            
            // 主要功能区域
            Section {
                mainFunctionsSection
            } header: {
                Text("主要功能")
            }
            
            // 数据管理区域
            Section {
                dataManagementSection
            } header: {
                Text("数据管理")
            }
            
            // 设置区域
            Section {
                settingsSection
            } header: {
                Text("设置")
            }
        }
        .navigationTitle("个人事务管理")
        .listStyle(SidebarListStyle())
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 12) {
                    // 快捷添加按钮
                    Menu {
                        Button(action: { showQuickActions = true }) {
                            Label("添加任务", systemImage: "plus.circle")
                        }
                        Button(action: { showQuickActions = true }) {
                            Label("添加财务记录", systemImage: "dollarsign.circle")
                        }
                        Button(action: { showQuickActions = true }) {
                            Label("添加密码", systemImage: "lock.shield")
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(DesignSystem.Colors.primary)
                    }
                    
                    // 主题切换按钮
                    Button(action: toggleTheme) {
                        Image(systemName: themeManager.isDarkMode ? "sun.max.fill" : "moon.fill")
                            .foregroundColor(DesignSystem.Colors.primary)
                    }
                }
            }
        }
    }
    
    // MARK: - 快捷操作区域
    private var quickActionsSection: some View {
        Group {
            SidebarRow(
                item: .pomodoro,
                icon: "timer",
                title: "番茄专注",
                color: DesignSystem.Colors.primary,
                subtitle: "立即开始专注"
            )
            
            SidebarRow(
                item: .dashboard,
                icon: "chart.bar.fill",
                title: "今日概览",
                color: DesignSystem.Colors.primary,
                subtitle: "查看今日进度"
            )
        }
    }
    
    // MARK: - 主要功能区域
    private var mainFunctionsSection: some View {
        Group {
            SidebarRow(
                item: .tasks,
                icon: "checklist",
                title: "任务管理",
                color: DesignSystem.Colors.task,
                badge: getTaskBadgeCount(),
                subtitle: "管理待办事项"
            )
            
            SidebarRow(
                item: .finance,
                icon: "dollarsign.circle.fill",
                title: "财务管理",
                color: DesignSystem.Colors.finance,
                subtitle: "收支记录与预算"
            )
            
            SidebarRow(
                item: .calendar,
                icon: "calendar",
                title: "日历",
                color: DesignSystem.Colors.calendar,
                subtitle: "日程安排"
            )
        }
    }
    
    // MARK: - 数据管理区域
    private var dataManagementSection: some View {
        Group {
            SidebarRow(
                item: .passwords,
                icon: "lock.shield.fill",
                title: "密码管理",
                color: DesignSystem.Colors.password,
                badge: getPasswordCount(),
                subtitle: "安全存储密码"
            )
            
            SidebarRow(
                item: .assets,
                icon: "creditcard.fill",
                title: "虚拟资产",
                color: DesignSystem.Colors.asset,
                badge: getAssetCount(),
                subtitle: "数字资产管理"
            )
            
            SidebarRow(
                item: .projects,
                icon: "folder.fill",
                title: "项目管理",
                color: DesignSystem.Colors.project,
                subtitle: "项目组织"
            )
        }
    }
    
    // MARK: - 设置区域
    private var settingsSection: some View {
        Group {
            SidebarRow(
                item: .sync,
                icon: "icloud.fill",
                title: "同步设置",
                color: DesignSystem.Colors.primary,
                subtitle: "云端数据同步"
            )
            
            SidebarRow(
                item: .settings,
                icon: "gear",
                title: "应用设置",
                color: DesignSystem.Colors.secondary,
                subtitle: "个性化配置"
            )
        }
    }
    
    // MARK: - 详情视图
    @ViewBuilder
    private var detailView: some View {
        if let selectedItem = selectedSidebarItem {
            switch selectedItem {
            case .dashboard:
                DashboardView()
            case .tasks:
                WorkTaskView()
            case .finance:
                FinancialManagementView()
            case .calendar:
                CalendarView()
            case .passwords:
                PasswordBoxView()
            case .assets:
                VirtualAssetsView()
            case .projects:
                ProjectManagementView()
            case .sync:
                SyncSettingsView()
            case .settings:
                SettingsView()
            case .pomodoro:
                PomodoroView()
            }
        } else {
            DashboardView()
        }
    }
    
    // MARK: - 辅助方法
    private func checkAuthenticationStatus() {
        // 模拟认证检查
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            isAuthenticated = true
            isLoading = false
        }
    }
    
    private func toggleTheme() {
        themeManager.toggleTheme()
    }
    
    private func getTaskBadgeCount() -> Int? {
        // 这里应该从数据源获取待处理任务数量
        return nil
    }
    
    private func getPasswordCount() -> Int? {
        // 这里应该从数据源获取密码数量
        return nil
    }
    
    private func getAssetCount() -> Int? {
        // 这里应该从数据源获取资产数量
        return nil
    }
}

// MARK: - 侧边栏项目
enum SidebarItem: Hashable, CaseIterable {
    case dashboard
    case tasks
    case finance
    case calendar
    case passwords
    case assets
    case projects
    case sync
    case settings
    case pomodoro
}

// MARK: - 侧边栏行组件
struct SidebarRow: View {
    let item: SidebarItem
    let icon: String
    let title: String
    let color: Color
    var badge: Int? = nil
    var subtitle: String? = nil
    
    var body: some View {
        NavigationLink(value: item) {
            HStack(spacing: 12) {
                // 图标
                Image(systemName: icon)
                    .foregroundColor(color)
                    .frame(width: 20, height: 20)
                
                // 内容
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text(title)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        Spacer()
                        
                        if let badge = badge, badge > 0 {
                            Text("\(badge)")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(DesignSystem.Colors.primary)
                                .clipShape(Capsule())
                        }
                    }
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundColor(DesignSystem.Colors.secondaryText)
                    }
                }
            }
            .padding(.vertical, 4)
        }
    }
}

// MARK: - 项目管理视图
struct ProjectManagementView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var projects: [Project]
    @State private var showingAddProject = false
    @State private var searchText = ""
    
    private var filteredProjects: [Project] {
        if searchText.isEmpty {
            return projects
        } else {
            return projects.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 搜索栏
                ModernSearchBar(
                    text: $searchText,
                    placeholder: "搜索项目..."
                )
                .padding(.horizontal, DesignSystem.Spacing.md)
                .padding(.vertical, DesignSystem.Spacing.sm)
                
                // 项目列表
                if filteredProjects.isEmpty {
                    EmptyStateView(
                        icon: "folder",
                        title: searchText.isEmpty ? "暂无项目" : "未找到相关项目",
                        subtitle: searchText.isEmpty ? "开始创建你的第一个项目吧" : "尝试调整搜索条件",
                        actionTitle: searchText.isEmpty ? "添加项目" : nil
                    ) {
                        if searchText.isEmpty {
                            showingAddProject = true
                        }
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: DesignSystem.Spacing.sm) {
                            ForEach(filteredProjects) { project in
                                ProjectRowView(project: project)
                            }
                        }
                        .padding(DesignSystem.Spacing.md)
                    }
                }
            }
            .background(DesignSystem.Colors.groupedBackground)
            .navigationTitle("项目管理")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddProject = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(DesignSystem.Colors.primary)
                    }
                }
            }
            .sheet(isPresented: $showingAddProject) {
                AddProjectView()
            }
        }
    }
}

// MARK: - 项目行视图
struct ProjectRowView: View {
    let project: Project
    @State private var showingDetail = false
    @State private var isPressed = false
    
    var body: some View {
        ModernCard {
            Button(action: { showingDetail = true }) {
                HStack(spacing: DesignSystem.Spacing.md) {
                    // 项目颜色标识
                    Circle()
                        .fill(Color(hex: project.colorHex) ?? DesignSystem.Colors.primary)
                        .frame(width: 12, height: 12)
                    
                    // 项目信息
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                        Text(project.name)
                            .font(DesignSystem.Typography.body)
                            .fontWeight(.medium)
                            .foregroundColor(DesignSystem.Colors.text)
                            .lineLimit(1)
                        
                        Text("创建于 \(project.createdAt.formatted(date: .abbreviated, time: .omitted))")
                            .font(DesignSystem.Typography.caption1)
                            .foregroundColor(DesignSystem.Colors.secondaryText)
                    }
                    
                    Spacer()
                    
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
            ProjectDetailView(project: project)
        }
    }
}

// MARK: - 项目详情视图
struct ProjectDetailView: View {
    let project: Project
    @Environment(\.dismiss) private var dismiss
    @State private var showingEdit = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: DesignSystem.Spacing.lg) {
                    // 项目标题
                    projectHeader
                    
                    // 项目统计
                    projectStatistics
                    
                    // 项目任务
                    projectTasks
                }
                .padding(DesignSystem.Spacing.md)
            }
            .background(DesignSystem.Colors.groupedBackground)
            .navigationTitle("项目详情")
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
                // EditProjectView(project: project)
                Text("编辑功能待实现")
            }
        }
    }
    
    private var projectHeader: some View {
        ModernCard {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                HStack {
                    Circle()
                        .fill(Color(hex: project.colorHex) ?? DesignSystem.Colors.primary)
                        .frame(width: 20, height: 20)
                    
                    Text(project.name)
                        .font(DesignSystem.Typography.title2)
                        .fontWeight(.bold)
                        .foregroundColor(DesignSystem.Colors.text)
                    
                    Spacer()
                }
                
                Text("创建于 \(project.createdAt.formatted(date: .complete, time: .shortened))")
                    .font(DesignSystem.Typography.caption1)
                    .foregroundColor(DesignSystem.Colors.secondaryText)
            }
        }
    }
    
    private var projectStatistics: some View {
        ModernCard {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                Text("项目统计")
                    .font(DesignSystem.Typography.headline)
                    .foregroundColor(DesignSystem.Colors.text)
                
                HStack(spacing: DesignSystem.Spacing.lg) {
                    StatCard(
                        title: "总任务",
                        value: "0", // 这里应该从数据源获取
                        icon: "checklist",
                        color: DesignSystem.Colors.task
                    )
                    
                    StatCard(
                        title: "已完成",
                        value: "0", // 这里应该从数据源获取
                        icon: "checkmark.circle",
                        color: DesignSystem.Colors.success
                    )
                    
                    StatCard(
                        title: "进行中",
                        value: "0", // 这里应该从数据源获取
                        icon: "play.circle",
                        color: DesignSystem.Colors.primary
                    )
                }
            }
        }
    }
    
    private var projectTasks: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("项目任务")
                .font(DesignSystem.Typography.headline)
                .foregroundColor(DesignSystem.Colors.text)
            
            ModernCard {
                EmptyStateView(
                    icon: "checklist",
                    title: "暂无任务",
                    subtitle: "为这个项目添加任务来开始工作",
                    actionTitle: "添加任务"
                ) {
                    // 添加任务操作
                }
            }
        }
    }
}

// MARK: - 设置视图
struct SettingsView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var cloudService: CloudService
    @State private var showingLogoutAlert = false
    
    var body: some View {
        NavigationStack {
            List {
                Section("外观") {
                    ModernToggle(
                        title: "深色模式",
                        isOn: $themeManager.isDarkMode,
                        icon: "moon.fill"
                    )
                }
                
                Section("同步") {
                    ModernToggle(
                        title: "自动同步",
                        isOn: .constant(true),
                        icon: "icloud.fill"
                    )
                    
                    InfoRow(
                        title: "同步状态",
                        value: "已连接",
                        icon: "checkmark.circle.fill"
                    )
                }
                
                Section("数据") {
                    InfoRow(
                        title: "数据备份",
                        value: "上次备份: 今天",
                        icon: "arrow.up.doc.fill"
                    )
                    
                    InfoRow(
                        title: "存储空间",
                        value: "已使用 2.3MB",
                        icon: "internaldrive.fill"
                    )
                }
                
                Section("关于") {
                    InfoRow(
                        title: "版本",
                        value: "1.0.0",
                        icon: "info.circle.fill"
                    )
                    
                    InfoRow(
                        title: "开发者",
                        value: "个人事务管理团队",
                        icon: "person.2.fill"
                    )
                }
                
                Section {
                    Button("退出登录") {
                        showingLogoutAlert = true
                    }
                    .foregroundColor(DesignSystem.Colors.error)
                }
            }
            .navigationTitle("设置")
            .navigationBarTitleDisplayMode(.large)
            .alert("确认退出", isPresented: $showingLogoutAlert) {
                Button("取消", role: .cancel) { }
                Button("退出", role: .destructive) {
                    // 执行退出登录
                }
            } message: {
                Text("确定要退出登录吗？")
            }
        }
    }
}

// MARK: - 同步间隔
enum SyncInterval: CaseIterable {
    case fifteenMinutes, thirtyMinutes, hourly, daily
    
    var title: String {
        switch self {
        case .fifteenMinutes: return "15分钟"
        case .thirtyMinutes: return "30分钟"
        case .hourly: return "每小时"
        case .daily: return "每天"
        }
    }
}

#Preview {
    AppRootView()
        .modelContainer(for: [WorkTask.self, FinancialRecord.self, Budget.self, Project.self, PasswordEntry.self, VirtualAsset.self], inMemory: true)
} 