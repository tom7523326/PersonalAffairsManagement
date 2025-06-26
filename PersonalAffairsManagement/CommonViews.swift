import SwiftUI
import SwiftData
import Combine

// MARK: - 信息行组件 - 增强交互
struct InfoRow: View {
    let title: String
    let value: String
    var canCopy: Bool = false
    var isLink: Bool = false
    var icon: String? = nil
    var action: (() -> Void)? = nil
    
    @State private var showingCopiedAlert = false
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            if let action = action {
                action()
            } else if canCopy {
                UIPasteboard.general.string = value
                showingCopiedAlert = true
            }
        }) {
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
                
                if canCopy || action != nil {
                    Image(systemName: canCopy ? "doc.on.doc" : "chevron.right")
                        .foregroundColor(DesignSystem.Colors.primary)
                        .font(.system(size: 16))
                        .opacity(isPressed ? 0.7 : 1.0)
                }
            }
            .padding(.vertical, DesignSystem.Spacing.sm)
            .padding(.horizontal, DesignSystem.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                    .fill(isPressed ? DesignSystem.Colors.secondaryBackground : Color.clear)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(DesignSystem.Animation.quick, value: isPressed)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
        .alert("已复制", isPresented: $showingCopiedAlert) {
            Button("确定") { }
        }
    }
}

// MARK: - 卡片组件 - 增强视觉效果
struct ModernCard<Content: View>: View {
    let content: Content
    var padding: CGFloat = DesignSystem.Spacing.md
    var shadow: Shadow = DesignSystem.Shadows.small
    var backgroundColor: Color = DesignSystem.Colors.cardBackground
    var borderColor: Color? = nil
    
    init(padding: CGFloat = DesignSystem.Spacing.md, 
         shadow: Shadow = DesignSystem.Shadows.small,
         backgroundColor: Color = DesignSystem.Colors.cardBackground,
         borderColor: Color? = nil,
         @ViewBuilder content: () -> Content) {
        self.padding = padding
        self.shadow = shadow
        self.backgroundColor = backgroundColor
        self.borderColor = borderColor
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(padding)
            .background(backgroundColor)
            .cornerRadius(DesignSystem.CornerRadius.md)
            .overlay(
                Group {
                    if let borderColor = borderColor {
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                            .stroke(borderColor, lineWidth: 1)
                    }
                }
            )
            .shadow(
                color: shadow.color,
                radius: shadow.radius,
                x: shadow.x,
                y: shadow.y
            )
    }
}

// MARK: - 按钮组件 - 增强交互反馈
struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    var icon: String? = nil
    var isLoading: Bool = false
    var isDisabled: Bool = false
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            if !isLoading && !isDisabled {
                action()
            }
        }) {
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
        .font(DesignSystem.Typography.headline)
        .foregroundColor(.white)
        .padding(.horizontal, DesignSystem.Spacing.lg)
        .padding(.vertical, DesignSystem.Spacing.md)
        .background(
            Group {
                if isDisabled {
                    DesignSystem.Colors.secondary
                } else {
                    DesignSystem.Colors.primaryGradient
                }
            }
        )
        .cornerRadius(DesignSystem.CornerRadius.md)
        .shadow(
            color: isDisabled ? Color.clear : DesignSystem.Colors.primary.opacity(0.3),
            radius: isPressed ? 2 : 4,
            x: 0,
            y: isPressed ? 1 : 2
        )
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .disabled(isLoading || isDisabled)
        .animation(DesignSystem.Animation.spring, value: isPressed)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

struct SecondaryButton: View {
    let title: String
    let action: () -> Void
    var icon: String? = nil
    var isDisabled: Bool = false
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            if !isDisabled {
                action()
            }
        }) {
            HStack(spacing: DesignSystem.Spacing.sm) {
                if let icon = icon {
                    Image(systemName: icon)
                }
                Text(title)
            }
        }
        .font(DesignSystem.Typography.headline)
        .foregroundColor(isDisabled ? DesignSystem.Colors.tertiaryText : DesignSystem.Colors.primary)
        .padding(.horizontal, DesignSystem.Spacing.lg)
        .padding(.vertical, DesignSystem.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                .fill(isDisabled ? DesignSystem.Colors.tertiaryBackground : DesignSystem.Colors.primaryLight)
        )
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                .stroke(
                    isDisabled ? DesignSystem.Colors.border : DesignSystem.Colors.primary.opacity(0.3),
                    lineWidth: 1
                )
        )
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .disabled(isDisabled)
        .animation(DesignSystem.Animation.spring, value: isPressed)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

// MARK: - 输入框组件 - 增强用户体验
struct ModernTextField: View {
    let placeholder: String
    @Binding var text: String
    var icon: String? = nil
    var keyboardType: UIKeyboardType = .default
    var textContentType: UITextContentType? = nil
    var isError: Bool = false
    var errorMessage: String? = nil
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
            HStack(spacing: DesignSystem.Spacing.sm) {
                if let icon = icon {
                    Image(systemName: icon)
                        .foregroundColor(isError ? DesignSystem.Colors.error : DesignSystem.Colors.secondaryText)
                }
                
                TextField(placeholder, text: $text)
                    .keyboardType(keyboardType)
                    .textContentType(textContentType)
                    .focused($isFocused)
            }
            .padding(DesignSystem.Spacing.md)
            .background(DesignSystem.Colors.secondaryBackground)
            .cornerRadius(DesignSystem.CornerRadius.sm)
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                    .stroke(
                        isError ? DesignSystem.Colors.error : (isFocused ? DesignSystem.Colors.primary : DesignSystem.Colors.border),
                        lineWidth: isFocused || isError ? 2 : 1
                    )
            )
            
            if let errorMessage = errorMessage, isError {
                Text(errorMessage)
                    .font(DesignSystem.Typography.caption1)
                    .foregroundColor(DesignSystem.Colors.error)
                    .padding(.leading, DesignSystem.Spacing.sm)
            }
        }
        .animation(DesignSystem.Animation.quick, value: isFocused)
        .animation(DesignSystem.Animation.quick, value: isError)
    }
}

struct ModernSecureField: View {
    let placeholder: String
    @Binding var text: String
    var icon: String? = nil
    var isError: Bool = false
    var errorMessage: String? = nil
    
    @FocusState private var isFocused: Bool
    @State private var isPasswordVisible = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
            HStack(spacing: DesignSystem.Spacing.sm) {
                if let icon = icon {
                    Image(systemName: icon)
                        .foregroundColor(isError ? DesignSystem.Colors.error : DesignSystem.Colors.secondaryText)
                }
                
                Group {
                    if isPasswordVisible {
                        TextField(placeholder, text: $text)
                    } else {
                        SecureField(placeholder, text: $text)
                    }
                }
                .focused($isFocused)
                
                Button(action: { isPasswordVisible.toggle() }) {
                    Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                }
            }
            .padding(DesignSystem.Spacing.md)
            .background(DesignSystem.Colors.secondaryBackground)
            .cornerRadius(DesignSystem.CornerRadius.sm)
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                    .stroke(
                        isError ? DesignSystem.Colors.error : (isFocused ? DesignSystem.Colors.primary : DesignSystem.Colors.border),
                        lineWidth: isFocused || isError ? 2 : 1
                    )
            )
            
            if let errorMessage = errorMessage, isError {
                Text(errorMessage)
                    .font(DesignSystem.Typography.caption1)
                    .foregroundColor(DesignSystem.Colors.error)
                    .padding(.leading, DesignSystem.Spacing.sm)
            }
        }
        .animation(DesignSystem.Animation.quick, value: isFocused)
        .animation(DesignSystem.Animation.quick, value: isError)
    }
}

// MARK: - 标签组件 - 增强选择反馈
struct ModernTag: View {
    let title: String
    let color: Color
    var isSelected: Bool = false
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(DesignSystem.Typography.caption1)
                .fontWeight(.medium)
                .padding(.horizontal, DesignSystem.Spacing.sm)
                .padding(.vertical, DesignSystem.Spacing.xs)
                .background(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.full)
                        .fill(isSelected ? color : DesignSystem.Colors.secondaryBackground)
                )
                .foregroundColor(isSelected ? .white : DesignSystem.Colors.text)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.full)
                        .stroke(isSelected ? color : DesignSystem.Colors.border, lineWidth: 1)
                )
        }
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(DesignSystem.Animation.quick, value: isPressed)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

// MARK: - 空状态组件 - 增强引导性
struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.xl) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(DesignSystem.Colors.secondaryText)
                .opacity(0.6)
            
            VStack(spacing: DesignSystem.Spacing.md) {
                Text(title)
                    .font(DesignSystem.Typography.title3)
                    .foregroundColor(DesignSystem.Colors.text)
                    .multilineTextAlignment(.center)
                
                Text(subtitle)
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(DesignSystem.Colors.secondaryText)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
            }
            
            if let actionTitle = actionTitle, let action = action {
                PrimaryButton(title: actionTitle, action: action, icon: "plus")
            }
        }
        .padding(DesignSystem.Spacing.xxl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - 加载状态组件 - 增强反馈
struct LoadingView: View {
    let message: String
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            ProgressView()
                .scaleEffect(1.2)
                .progressViewStyle(CircularProgressViewStyle(tint: DesignSystem.Colors.primary))
            
            Text(message)
                .font(DesignSystem.Typography.body)
                .foregroundColor(DesignSystem.Colors.secondaryText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DesignSystem.Colors.background)
    }
}

// MARK: - 搜索栏组件 - 增强交互
struct ModernSearchBar: View {
    @Binding var text: String
    let placeholder: String
    var onSearch: (() -> Void)? = nil
    var onClear: (() -> Void)? = nil
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(DesignSystem.Colors.secondaryText)
            
            TextField(placeholder, text: $text)
                .textFieldStyle(PlainTextFieldStyle())
                .focused($isFocused)
                .onSubmit {
                    onSearch?()
                }
            
            if !text.isEmpty {
                Button(action: { 
                    text = ""
                    onClear?()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                        .font(.system(size: 16))
                }
            }
        }
        .padding(DesignSystem.Spacing.md)
        .background(DesignSystem.Colors.secondaryBackground)
        .cornerRadius(DesignSystem.CornerRadius.md)
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                .stroke(isFocused ? DesignSystem.Colors.primary : DesignSystem.Colors.border, lineWidth: isFocused ? 2 : 1)
        )
        .animation(DesignSystem.Animation.quick, value: isFocused)
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

// MARK: - 徽章组件 - 增强视觉效果
struct ModernBadge: View {
    let text: String
    let color: Color
    var size: BadgeSize = .medium
    var isAnimated: Bool = false
    
    @State private var isAnimating = false
    
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
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(.horizontal, size.padding)
            .padding(.vertical, size.padding / 2)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.full)
                    .fill(color)
            )
            .scaleEffect(isAnimating ? 1.1 : 1.0)
            .animation(
                isAnimated ? DesignSystem.Animation.spring.repeatForever(autoreverses: true) : nil,
                value: isAnimating
            )
            .onAppear {
                if isAnimated {
                    isAnimating = true
                }
            }
    }
}

// MARK: - 开关组件
struct ModernToggle: View {
    let title: String
    @Binding var isOn: Bool
    var icon: String? = nil
    
    var body: some View {
        HStack {
            if let icon = icon {
                Image(systemName: icon)
                    .foregroundColor(DesignSystem.Colors.secondaryText)
                    .frame(width: 20)
            }
            
            Text(title)
                .font(DesignSystem.Typography.body)
                .foregroundColor(DesignSystem.Colors.text)
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .toggleStyle(SwitchToggleStyle(tint: DesignSystem.Colors.primary))
        }
        .padding(.vertical, DesignSystem.Spacing.sm)
    }
}

// MARK: - 选择器组件
struct ModernPicker<SelectionValue: Hashable>: View {
    let title: String
    @Binding var selection: SelectionValue
    let options: [(SelectionValue, String)]
    var icon: String? = nil
    
    var body: some View {
        HStack {
            if let icon = icon {
                Image(systemName: icon)
                    .foregroundColor(DesignSystem.Colors.secondaryText)
                    .frame(width: 20)
            }
            
            Text(title)
                .font(DesignSystem.Typography.body)
                .foregroundColor(DesignSystem.Colors.text)
            
            Spacer()
            
            Picker("", selection: $selection) {
                ForEach(options, id: \.0) { option in
                    Text(option.1).tag(option.0)
                }
            }
            .pickerStyle(MenuPickerStyle())
        }
        .padding(.vertical, DesignSystem.Spacing.sm)
    }
}

// MARK: - 预览
#Preview {
    ScrollView {
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
            ModernSecureField(placeholder: "输入密码", text: .constant(""), icon: "lock")
            
            HStack {
                ModernTag(title: "标签1", color: .blue, isSelected: true) {}
                ModernTag(title: "标签2", color: .green) {}
            }
            
            ModernBadge(text: "新", color: .red, isAnimated: true)
            
            ModernToggle(title: "开关选项", isOn: .constant(true), icon: "bell")
            
            ModernSearchBar(text: .constant(""), placeholder: "搜索...")
        }
        .padding()
    }
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
                        .navigationTitle("添加任务")
                        .navigationBarTitleDisplayMode(.inline)
                case .financialRecord:
                    AddFinancialRecordView()
                        .navigationTitle("添加财务记录")
                        .navigationBarTitleDisplayMode(.inline)
                case .password:
                    AddPasswordView()
                        .navigationTitle("添加密码")
                        .navigationBarTitleDisplayMode(.inline)
                case .virtualAsset:
                    AddAssetView()
                        .navigationTitle("添加虚拟资产")
                        .navigationBarTitleDisplayMode(.inline)
                }
            }
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