import SwiftUI
import SwiftData

struct AppRootView: View {
    @State private var selection: SidebarItem? = .dashboard
    @State private var showingAddSheet = false
    @State private var addSheetType: AddSheetType? = nil
    
    var body: some View {
        NavigationSplitView {
            ModernSidebarView(selection: $selection) { type in
                addSheetType = type
                showingAddSheet = true
            }
        } detail: {
            DetailContentView(selection: selection)
        }
        .sheet(isPresented: $showingAddSheet) {
            if let type = addSheetType {
                AddItemSheet(type: type)
            }
        }
    }
}

// MARK: - 现代化侧边栏
struct ModernSidebarView: View {
    @Binding var selection: SidebarItem?
    let onAddItem: (AddSheetType) -> Void
    
    @Query private var projects: [Project]
    @Query private var allTasks: [WorkTask]
    @State private var isCollapsed = false
    
    var body: some View {
        List(selection: $selection) {
            // 主要功能区域
            Section("概览") {
                SidebarRow(
                    item: .dashboard,
                    icon: "chart.bar.fill",
                    title: "仪表板",
                    color: .blue
                )
            }
            
            // 任务管理区域
            Section("任务管理") {
                SidebarRow(
                    item: .inbox,
                    icon: "tray.fill",
                    title: "收件箱",
                    badge: getInboxCount()
                )
                
                SidebarRow(
                    item: .today,
                    icon: "calendar",
                    title: "今日任务",
                    badge: getTodayCount()
                )
                
                SidebarRow(
                    item: .upcoming,
                    icon: "calendar.badge.clock",
                    title: "即将到期",
                    badge: getUpcomingCount()
                )
                
                SidebarRow(
                    item: .all,
                    icon: "list.bullet",
                    title: "所有任务"
                )
                
                // 项目列表
                if !projects.isEmpty {
                    ForEach(projects) { project in
                        SidebarRow(
                            item: .project(project),
                            icon: "folder.fill",
                            title: project.name,
                            color: project.color
                        )
                    }
                }
            }
            
            // 财务管理区域
            Section("财务管理") {
                SidebarRow(
                    item: .financial,
                    icon: "creditcard.fill",
                    title: "财务记录",
                    color: .green
                )
            }
            
            // 个人管理区域
            Section("个人管理") {
                SidebarRow(
                    item: .passwordBox,
                    icon: "lock.shield.fill",
                    title: "密码箱",
                    color: .purple
                )
                
                SidebarRow(
                    item: .virtualAssets,
                    icon: "gift.fill",
                    title: "虚拟资产",
                    color: .orange
                )
            }
            
            // 工具区域
            Section("工具") {
                SidebarRow(
                    item: .calendar,
                    icon: "calendar.badge.plus",
                    title: "日历视图",
                    color: .red
                )
                
                SidebarRow(
                    item: .syncSettings,
                    icon: "icloud",
                    title: "云端同步",
                    color: .blue
                )
            }
        }
        .listStyle(SidebarListStyle())
        .navigationTitle("个人事务管理")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button("添加任务") { onAddItem(.task) }
                    Button("添加财务记录") { onAddItem(.financialRecord) }
                    Button("添加密码") { onAddItem(.password) }
                    Button("添加虚拟资产") { onAddItem(.virtualAsset) }
                    Button("添加项目") { onAddItem(.project) }
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(DesignSystem.Colors.primary)
                }
            }
        }
    }
    
    private func getInboxCount() -> Int {
        return allTasks.filter { $0.status == .pending && $0.project == nil }.count
    }
    
    private func getTodayCount() -> Int {
        let calendar = Calendar.current
        let today = Date()
        return allTasks.filter { task in
            guard let dueDate = task.dueDate else { return false }
            return calendar.isDate(dueDate, inSameDayAs: today) && task.status != .completed
        }.count
    }
    
    private func getUpcomingCount() -> Int {
        let calendar = Calendar.current
        let now = Date()
        let nextWeek = calendar.date(byAdding: .day, value: 7, to: now) ?? now
        return allTasks.filter { task in
            guard let dueDate = task.dueDate else { return false }
            return dueDate > now && dueDate <= nextWeek && task.status != .completed
        }.count
    }
}

// MARK: - 侧边栏行组件
struct SidebarRow: View {
    let item: SidebarItem
    let icon: String
    let title: String
    var color: Color = DesignSystem.Colors.primary
    var badge: Int? = nil
    
    var body: some View {
        NavigationLink(value: item) {
            HStack(spacing: DesignSystem.Spacing.sm) {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .frame(width: 20)
                
                Text(title)
                    .font(DesignSystem.Typography.body)
                
                Spacer()
                
                if let badge = badge, badge > 0 {
                    ModernBadge(text: "\(badge)", color: color, size: .small)
                }
            }
        }
    }
}

// MARK: - 详情内容视图
struct DetailContentView: View {
    let selection: SidebarItem?
    
    var body: some View {
        Group {
            if let selection = selection {
                switch selection {
                case .inbox:
                    WorkTaskView(filter: .inbox)
                case .today:
                    WorkTaskView(filter: .today)
                case .upcoming:
                    WorkTaskView(filter: .upcoming)
                case .all:
                    WorkTaskView(filter: .all)
                case .calendar:
                    CalendarView()
                case .project(let project):
                    WorkTaskView(filter: .project(project))
                case .financial:
                    FinancialManagementView()
                case .dashboard:
                    DashboardView()
                case .passwordBox:
                    PasswordBoxView()
                case .virtualAssets:
                    VirtualAssetsView()
                case .syncSettings:
                    SyncSettingsView()
                }
            } else {
                // 默认显示仪表板
                DashboardView()
            }
        }
        .animation(DesignSystem.Animation.standard, value: selection)
    }
}

// MARK: - 侧边栏项目类型
enum SidebarItem: Hashable {
    case inbox
    case today
    case upcoming
    case all
    case calendar
    case project(Project)
    case financial
    case dashboard
    case passwordBox
    case virtualAssets
    case syncSettings
}

#Preview {
    AppRootView()
        .modelContainer(for: [WorkTask.self, FinancialRecord.self, Budget.self, Project.self, PasswordEntry.self, VirtualAsset.self], inMemory: true)
} 