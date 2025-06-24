import SwiftUI
import SwiftData
import Combine

// MARK: - 信息行组件
struct InfoRow: View {
    let title: String
    let value: String
    var canCopy: Bool = false
    var isLink: Bool = false
    var icon: String? = nil
    
    @State private var showingCopiedAlert = false
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            if let icon = icon {
                Image(systemName: icon)
                    .foregroundColor(DesignSystem.Colors.secondaryText)
                    .frame(width: 20)
            }
            
            Text(title)
                .font(DesignSystem.Typography.subheadline)
                .foregroundColor(DesignSystem.Colors.secondaryText)
                .frame(width: 80, alignment: .leading)
            
            if isLink {
                Link(value, destination: URL(string: value) ?? URL(string: "https://example.com")!)
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(DesignSystem.Colors.primary)
            } else {
                Text(value)
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(DesignSystem.Colors.text)
            }
            
            Spacer()
            
            if canCopy {
                Button(action: {
                    UIPasteboard.general.string = value
                    showingCopiedAlert = true
                }) {
                    Image(systemName: "doc.on.doc")
                        .foregroundColor(DesignSystem.Colors.primary)
                        .font(.system(size: 16))
                }
                .alert("已复制", isPresented: $showingCopiedAlert) {
                    Button("确定") { }
                }
            }
        }
        .padding(.vertical, DesignSystem.Spacing.xs)
    }
}

// MARK: - 卡片组件
struct ModernCard<Content: View>: View {
    let content: Content
    var padding: CGFloat = DesignSystem.Spacing.md
    var shadow: Shadow = DesignSystem.Shadows.small
    
    init(padding: CGFloat = DesignSystem.Spacing.md, shadow: Shadow = DesignSystem.Shadows.small, @ViewBuilder content: () -> Content) {
        self.padding = padding
        self.shadow = shadow
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(padding)
            .background(DesignSystem.Colors.cardBackground)
            .cornerRadius(DesignSystem.CornerRadius.md)
            .shadow(
                color: shadow.color,
                radius: shadow.radius,
                x: shadow.x,
                y: shadow.y
            )
    }
}

// MARK: - 按钮组件
struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    var icon: String? = nil
    var isLoading: Bool = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: DesignSystem.Spacing.sm) {
                if isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else if let icon = icon {
                    Image(systemName: icon)
                }
                
                Text(title)
            }
        }
        .primaryButtonStyle()
        .disabled(isLoading)
    }
}

struct SecondaryButton: View {
    let title: String
    let action: () -> Void
    var icon: String? = nil
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: DesignSystem.Spacing.sm) {
                if let icon = icon {
                    Image(systemName: icon)
                }
                Text(title)
            }
        }
        .secondaryButtonStyle()
    }
}

// MARK: - 输入框组件
struct ModernTextField: View {
    let placeholder: String
    @Binding var text: String
    var icon: String? = nil
    var keyboardType: UIKeyboardType = .default
    var textContentType: UITextContentType? = nil
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            if let icon = icon {
                Image(systemName: icon)
                    .foregroundColor(DesignSystem.Colors.secondaryText)
            }
            
            TextField(placeholder, text: $text)
                .keyboardType(keyboardType)
                .textContentType(textContentType)
        }
        .inputFieldStyle()
    }
}

struct ModernSecureField: View {
    let placeholder: String
    @Binding var text: String
    var icon: String? = nil
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            if let icon = icon {
                Image(systemName: icon)
                    .foregroundColor(DesignSystem.Colors.secondaryText)
            }
            
            SecureField(placeholder, text: $text)
        }
        .inputFieldStyle()
    }
}

// MARK: - 标签组件
struct ModernTag: View {
    let title: String
    let color: Color
    var isSelected: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(DesignSystem.Typography.caption1)
                .fontWeight(.medium)
                .padding(.horizontal, DesignSystem.Spacing.sm)
                .padding(.vertical, DesignSystem.Spacing.xs)
                .background(isSelected ? color : DesignSystem.Colors.secondaryBackground)
                .foregroundColor(isSelected ? .white : DesignSystem.Colors.text)
                .cornerRadius(DesignSystem.CornerRadius.full)
        }
    }
}

// MARK: - 空状态组件
struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(DesignSystem.Colors.secondaryText)
            
            VStack(spacing: DesignSystem.Spacing.sm) {
                Text(title)
                    .font(DesignSystem.Typography.title3)
                    .foregroundColor(DesignSystem.Colors.text)
                
                Text(subtitle)
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(DesignSystem.Colors.secondaryText)
                    .multilineTextAlignment(.center)
            }
            
            if let actionTitle = actionTitle, let action = action {
                PrimaryButton(title: actionTitle, action: action)
            }
        }
        .padding(DesignSystem.Spacing.xl)
    }
}

// MARK: - 加载状态组件
struct LoadingView: View {
    let message: String
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            ProgressView()
                .scaleEffect(1.2)
                .progressViewStyle(CircularProgressViewStyle(tint: .blue))
            Text(message)
                .font(DesignSystem.Typography.body)
                .foregroundColor(DesignSystem.Colors.secondaryText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

// MARK: - 搜索栏组件
struct ModernSearchBar: View {
    @Binding var text: String
    let placeholder: String
    var onSearch: (() -> Void)? = nil
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(DesignSystem.Colors.secondaryText)
            
            TextField(placeholder, text: $text)
                .textFieldStyle(PlainTextFieldStyle())
                .onSubmit {
                    onSearch?()
                }
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                }
            }
        }
        .padding(DesignSystem.Spacing.md)
        .background(DesignSystem.Colors.secondaryBackground)
        .cornerRadius(DesignSystem.CornerRadius.md)
    }
}

// MARK: - 分割线组件
struct ModernDivider: View {
    var color: Color = DesignSystem.Colors.divider
    var padding: CGFloat = DesignSystem.Spacing.md
    
    var body: some View {
        Rectangle()
            .fill(color)
            .frame(height: 1)
            .padding(.horizontal, padding)
    }
}

// MARK: - 徽章组件
struct ModernBadge: View {
    let text: String
    let color: Color
    var size: BadgeSize = .medium
    
    enum BadgeSize {
        case small, medium, large
        
        var fontSize: Font {
            switch self {
            case .small: return DesignSystem.Typography.caption2
            case .medium: return DesignSystem.Typography.caption1
            case .large: return DesignSystem.Typography.footnote
            }
        }
        
        var padding: CGFloat {
            switch self {
            case .small: return DesignSystem.Spacing.xs
            case .medium: return DesignSystem.Spacing.sm
            case .large: return DesignSystem.Spacing.md
            }
        }
    }
    
    var body: some View {
        Text(text)
            .font(size.fontSize)
            .fontWeight(.medium)
            .foregroundColor(.white)
            .padding(.horizontal, size.padding)
            .padding(.vertical, size.padding / 2)
            .background(color)
            .cornerRadius(DesignSystem.CornerRadius.full)
    }
}

// MARK: - 预览
#Preview {
    VStack(spacing: DesignSystem.Spacing.lg) {
        InfoRow(title: "标题", value: "内容", canCopy: true, icon: "doc.text")
        InfoRow(title: "链接", value: "https://example.com", canCopy: true, isLink: true, icon: "link")
        
        ModernCard {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                Text("卡片标题")
                    .font(DesignSystem.Typography.headline)
                Text("卡片内容")
                    .font(DesignSystem.Typography.body)
            }
        }
        
        HStack {
            PrimaryButton(title: "主要按钮", action: {})
            SecondaryButton(title: "次要按钮", action: {})
        }
        
        ModernTextField(placeholder: "输入文本", text: .constant(""), icon: "textformat")
        
        HStack {
            ModernTag(title: "标签1", color: .blue, isSelected: true) {}
            ModernTag(title: "标签2", color: .green) {}
        }
        
        ModernBadge(text: "新", color: .red)
    }
    .padding()
}

// MARK: - 添加项目类型
enum AddSheetType {
    case task
    case financialRecord
    case password
    case virtualAsset
    case project
}

// MARK: - 添加项目表单
struct AddItemSheet: View {
    let type: AddSheetType
    
    var body: some View {
        NavigationView {
            Group {
                switch type {
                case .task:
                    AddTaskView()
                case .financialRecord:
                    AddFinancialRecordView()
                case .password:
                    AddPasswordView()
                case .virtualAsset:
                    AddAssetView()
                case .project:
                    AddProjectView()
                }
            }
            .navigationTitle(getTitle())
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func getTitle() -> String {
        switch type {
        case .task: return "添加任务"
        case .financialRecord: return "添加财务记录"
        case .password: return "添加密码"
        case .virtualAsset: return "添加虚拟资产"
        case .project: return "添加项目"
        }
    }
}

// MARK: - 数据查询管理器
@MainActor
class DataQueryManager: ObservableObject {
    @Published var tasks: [WorkTask] = []
    @Published var records: [FinancialRecord] = []
    @Published var budgets: [Budget] = []
    @Published var passwords: [PasswordEntry] = []
    @Published var assets: [VirtualAsset] = []
    @Published var projects: [Project] = []
    
    // 分页支持
    @Published var isLoadingMore = false
    @Published var hasMoreData = true
    private let pageSize = 50
    private var currentPage = 0
    
    // 缓存支持
    private var cache = NSCache<NSString, AnyObject>()
    private let cacheTimeout: TimeInterval = 300 // 5分钟
    
    // 加载状态
    @Published var isLoading = false
    @Published var lastRefreshTime: Date?
    
    private var modelContext: ModelContext?
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // 空的初始化，稍后设置modelContext
    }
    
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
        loadData()
        setupDataObservers()
    }
    
    private func setupDataObservers() {
        guard let modelContext = modelContext else { return }
        
        // 监听数据变化并自动刷新
        NotificationCenter.default.publisher(for: .NSManagedObjectContextDidSave, object: modelContext)
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.refreshData()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - 数据加载
    func loadData() {
        guard let modelContext = modelContext else { return }
        
        isLoading = true
        
        Task {
            await loadDataAsync(modelContext: modelContext)
        }
    }
    
    private func loadDataAsync(modelContext: ModelContext) async {
        defer { isLoading = false }
        
        // 检查缓存
        if let cachedData = getCachedData() {
            await MainActor.run {
                self.applyCachedData(cachedData)
            }
            return
        }
        
        do {
            let projects = try modelContext.fetch(FetchDescriptor<Project>())
            let tasks = try modelContext.fetch(FetchDescriptor<WorkTask>())
            let records = try modelContext.fetch(FetchDescriptor<FinancialRecord>())
            let budgets = try modelContext.fetch(FetchDescriptor<Budget>())
            let passwords = try modelContext.fetch(FetchDescriptor<PasswordEntry>())
            let assets = try modelContext.fetch(FetchDescriptor<VirtualAsset>())
            
            await MainActor.run {
                self.projects = projects
                self.tasks = tasks
                self.records = records
                self.budgets = budgets
                self.passwords = passwords
                self.assets = assets
                self.lastRefreshTime = Date()
                
                // 缓存数据
                self.cacheData()
            }
        } catch {
            await MainActor.run {
                ErrorHandler.shared.handle(AppError.dataError("加载数据失败: \(error.localizedDescription)"))
            }
        }
    }
    
    // MARK: - 分页加载
    func loadMoreData() {
        guard !isLoadingMore && hasMoreData else { return }
        
        isLoadingMore = true
        currentPage += 1
        
        Task {
            await loadMoreDataAsync()
        }
    }
    
    private func loadMoreDataAsync() async {
        defer { isLoadingMore = false }
        
        guard let modelContext = modelContext else { return }
        
        do {
            // 这里可以实现真正的分页逻辑
            // 目前简单返回，因为SwiftData的FetchDescriptor分页支持有限
            hasMoreData = false
        } catch {
            await MainActor.run {
                ErrorHandler.shared.handle(AppError.dataError("加载更多数据失败: \(error.localizedDescription)"))
            }
        }
    }
    
    // MARK: - 刷新数据
    func refreshData() {
        clearCache()
        loadData()
    }
    
    // MARK: - 缓存管理
    private func cacheData() {
        let cacheData = CacheData(
            projects: projects,
            tasks: tasks,
            records: records,
            budgets: budgets,
            passwords: passwords,
            assets: assets,
            timestamp: Date()
        )
        
        cache.setObject(cacheData, forKey: "main_data" as NSString)
    }
    
    private func getCachedData() -> CacheData? {
        guard let cachedData = cache.object(forKey: "main_data" as NSString) as? CacheData else {
            return nil
        }
        
        // 检查缓存是否过期
        if Date().timeIntervalSince(cachedData.timestamp) > cacheTimeout {
            cache.removeObject(forKey: "main_data" as NSString)
            return nil
        }
        
        return cachedData
    }
    
    private func applyCachedData(_ cachedData: CacheData) {
        self.projects = cachedData.projects
        self.tasks = cachedData.tasks
        self.records = cachedData.records
        self.budgets = cachedData.budgets
        self.passwords = cachedData.passwords
        self.assets = cachedData.assets
        self.lastRefreshTime = cachedData.timestamp
    }
    
    private func clearCache() {
        cache.removeAllObjects()
    }
    
    // MARK: - 数据统计
    var totalTasks: Int { tasks.count }
    var completedTasks: Int { tasks.filter { $0.status == .completed }.count }
    var pendingTasks: Int { tasks.filter { $0.status == .pending }.count }
    
    var totalRecords: Int { records.count }
    var totalIncome: Double { records.filter { $0.type == .income }.reduce(0) { $0 + $1.amount } }
    var totalExpense: Double { records.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount } }
    
    var totalBudgets: Int { budgets.count }
    var totalPasswords: Int { passwords.count }
    var totalAssets: Int { assets.count }
    var totalProjects: Int { projects.count }
    
    // MARK: - 搜索功能
    func searchTasks(query: String) -> [WorkTask] {
        guard !query.isEmpty else { return tasks }
        return tasks.filter { task in
            task.title.localizedCaseInsensitiveContains(query) ||
            task.taskDescription.localizedCaseInsensitiveContains(query)
        }
    }
    
    func searchRecords(query: String) -> [FinancialRecord] {
        guard !query.isEmpty else { return records }
        return records.filter { record in
            record.title.localizedCaseInsensitiveContains(query) ||
            record.recordDescription.localizedCaseInsensitiveContains(query)
        }
    }
    
    func searchPasswords(query: String) -> [PasswordEntry] {
        guard !query.isEmpty else { return passwords }
        return passwords.filter { password in
            password.title.localizedCaseInsensitiveContains(query) ||
            password.username.localizedCaseInsensitiveContains(query) ||
            (password.website?.localizedCaseInsensitiveContains(query) ?? false)
        }
    }
}

// MARK: - 缓存数据模型
private class CacheData: NSObject {
    let projects: [Project]
    let tasks: [WorkTask]
    let records: [FinancialRecord]
    let budgets: [Budget]
    let passwords: [PasswordEntry]
    let assets: [VirtualAsset]
    let timestamp: Date
    
    init(projects: [Project], tasks: [WorkTask], records: [FinancialRecord], budgets: [Budget], passwords: [PasswordEntry], assets: [VirtualAsset], timestamp: Date) {
        self.projects = projects
        self.tasks = tasks
        self.records = records
        self.budgets = budgets
        self.passwords = passwords
        self.assets = assets
        self.timestamp = timestamp
    }
}

// MARK: - 任务过滤器枚举
enum TaskFilter {
    case inbox
    case today
    case upcoming
    case all
    case project(Project)
} 