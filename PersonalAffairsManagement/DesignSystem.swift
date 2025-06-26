import SwiftUI

// MARK: - 设计系统
struct DesignSystem {
    
    // MARK: - 颜色系统
    struct Colors {
        // 主色调 - 支持动态主题
        static let primary = Color.blue
        static let primaryLight = Color.blue.opacity(0.1)
        static let primaryDark = Color.blue.opacity(0.8)
        static let primaryGradient = LinearGradient(
            colors: [primary, primary.opacity(0.8)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        // 辅助色
        static let secondary = Color.gray
        static let accent = Color.orange
        static let accentLight = Color.orange.opacity(0.1)
        
        // 语义色 - 增强对比度
        static let success = Color.green
        static let successLight = Color.green.opacity(0.1)
        static let warning = Color.yellow
        static let warningLight = Color.yellow.opacity(0.1)
        static let error = Color.red
        static let errorLight = Color.red.opacity(0.1)
        static let info = Color.blue
        static let infoLight = Color.blue.opacity(0.1)
        
        // 中性色 - 支持深色模式
        static let background = Color(.systemBackground)
        static let secondaryBackground = Color(.secondarySystemBackground)
        static let tertiaryBackground = Color(.tertiarySystemBackground)
        static let groupedBackground = Color(.systemGroupedBackground)
        
        static let text = Color(.label)
        static let secondaryText = Color(.secondaryLabel)
        static let tertiaryText = Color(.tertiaryLabel)
        static let quaternaryText = Color(.quaternaryLabel)
        
        // 边框和分割线
        static let border = Color(.separator)
        static let divider = Color(.opaqueSeparator)
        static let borderLight = Color(.separator).opacity(0.5)
        
        // 卡片背景 - 增强层次感
        static let cardBackground = Color(.systemBackground)
        static let cardShadow = Color.black.opacity(0.08)
        static let cardShadowHover = Color.black.opacity(0.12)
        
        // 功能色彩
        static let task = Color.blue
        static let finance = Color.green
        static let password = Color.purple
        static let asset = Color.orange
        static let calendar = Color.red
        static let project = Color.indigo
    }
    
    // MARK: - 字体系统 - 优化可读性
    struct Typography {
        // 标题字体 - 增强层次
        static let largeTitle = Font.largeTitle.weight(.bold)
        static let title1 = Font.title.weight(.bold)
        static let title2 = Font.title2.weight(.semibold)
        static let title3 = Font.title3.weight(.semibold)
        
        // 正文字体 - 优化行高
        static let headline = Font.headline.weight(.semibold)
        static let body = Font.body
        static let callout = Font.callout
        static let subheadline = Font.subheadline
        static let footnote = Font.footnote
        static let caption1 = Font.caption
        static let caption2 = Font.caption2
        
        // 特殊字体
        static let monospaced = Font.system(.body, design: .monospaced)
        static let rounded = Font.system(.body, design: .rounded)
        
        // 数字字体 - 财务显示
        static let number = Font.system(.title2, design: .rounded).weight(.semibold)
        static let numberLarge = Font.system(.title, design: .rounded).weight(.bold)
    }
    
    // MARK: - 间距系统 - 8px基础网格
    struct Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
        static let xxxl: CGFloat = 64
    }
    
    // MARK: - 圆角系统 - 统一视觉语言
    struct CornerRadius {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
        static let xxl: CGFloat = 24
        static let full: CGFloat = 999
    }
    
    // MARK: - 阴影系统 - 增强深度感
    struct Shadows {
        static let none = Shadow(color: .clear, radius: 0, x: 0, y: 0)
        static let small = Shadow(color: .black.opacity(0.08), radius: 2, x: 0, y: 1)
        static let medium = Shadow(color: .black.opacity(0.12), radius: 4, x: 0, y: 2)
        static let large = Shadow(color: .black.opacity(0.16), radius: 8, x: 0, y: 4)
        static let xlarge = Shadow(color: .black.opacity(0.20), radius: 16, x: 0, y: 8)
    }
    
    // MARK: - 动画系统 - 流畅交互
    struct Animation {
        static let quick = SwiftUI.Animation.easeInOut(duration: 0.15)
        static let standard = SwiftUI.Animation.easeInOut(duration: 0.25)
        static let slow = SwiftUI.Animation.easeInOut(duration: 0.4)
        static let spring = SwiftUI.Animation.spring(response: 0.4, dampingFraction: 0.8)
        static let bouncy = SwiftUI.Animation.spring(response: 0.3, dampingFraction: 0.6)
    }
    
    // MARK: - 布局系统
    struct Layout {
        static let maxWidth: CGFloat = 500
        static let cardPadding: CGFloat = 16
        static let listSpacing: CGFloat = 12
        static let sectionSpacing: CGFloat = 24
    }
}

// MARK: - 阴影结构
struct Shadow {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

// MARK: - 扩展View以支持设计系统
extension View {
    // 应用卡片样式 - 增强视觉层次
    func cardStyle(shadow: Shadow = DesignSystem.Shadows.small) -> some View {
        self
            .background(DesignSystem.Colors.cardBackground)
            .cornerRadius(DesignSystem.CornerRadius.md)
            .shadow(
                color: shadow.color,
                radius: shadow.radius,
                x: shadow.x,
                y: shadow.y
            )
    }
    
    // 应用主要按钮样式 - 增强交互反馈
    func primaryButtonStyle() -> some View {
        self
            .font(DesignSystem.Typography.headline)
            .foregroundColor(.white)
            .padding(.horizontal, DesignSystem.Spacing.lg)
            .padding(.vertical, DesignSystem.Spacing.md)
            .background(DesignSystem.Colors.primaryGradient)
            .cornerRadius(DesignSystem.CornerRadius.md)
            .shadow(color: DesignSystem.Colors.primary.opacity(0.3), radius: 4, x: 0, y: 2)
    }
    
    // 应用次要按钮样式
    func secondaryButtonStyle() -> some View {
        self
            .font(DesignSystem.Typography.headline)
            .foregroundColor(DesignSystem.Colors.primary)
            .padding(.horizontal, DesignSystem.Spacing.lg)
            .padding(.vertical, DesignSystem.Spacing.md)
            .background(DesignSystem.Colors.primaryLight)
            .cornerRadius(DesignSystem.CornerRadius.md)
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                    .stroke(DesignSystem.Colors.primary.opacity(0.3), lineWidth: 1)
            )
    }
    
    // 应用输入框样式 - 增强可用性
    func inputFieldStyle() -> some View {
        self
            .padding(DesignSystem.Spacing.md)
            .background(DesignSystem.Colors.secondaryBackground)
            .cornerRadius(DesignSystem.CornerRadius.sm)
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                    .stroke(DesignSystem.Colors.border, lineWidth: 1)
            )
    }
    
    // 应用列表项样式
    func listItemStyle() -> some View {
        self
            .padding(DesignSystem.Spacing.md)
            .background(DesignSystem.Colors.cardBackground)
            .cornerRadius(DesignSystem.CornerRadius.sm)
    }
    
    // 应用标签样式
    func tagStyle(color: Color = DesignSystem.Colors.primary) -> some View {
        self
            .font(DesignSystem.Typography.caption1)
            .fontWeight(.medium)
            .foregroundColor(color)
            .padding(.horizontal, DesignSystem.Spacing.sm)
            .padding(.vertical, DesignSystem.Spacing.xs)
            .background(color.opacity(0.1))
            .cornerRadius(DesignSystem.CornerRadius.full)
    }
}

// MARK: - 预定义颜色资源
extension Color {
    static let systemPrimary = Color.blue
    static let systemSecondary = Color.gray
    static let systemBackground = Color(.systemBackground)
    static let systemCardBackground = Color(.systemBackground)
    
    // 功能色彩扩展
    static let taskColor = Color.blue
    static let financeColor = Color.green
    static let passwordColor = Color.purple
    static let assetColor = Color.orange
    static let calendarColor = Color.red
    static let projectColor = Color.indigo
}

// MARK: - 主题管理器
class ThemeManager: ObservableObject {
    @Published var isDarkMode: Bool = false
    @Published var accentColor: Color = .blue
    
    static let shared = ThemeManager()
    
    private init() {
        // 从UserDefaults读取主题设置
        isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        if let colorData = UserDefaults.standard.data(forKey: "accentColor"),
           let color = try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: colorData) {
            accentColor = Color(color)
        }
    }
    
    func toggleTheme() {
        isDarkMode.toggle()
        UserDefaults.standard.set(isDarkMode, forKey: "isDarkMode")
    }
    
    func setAccentColor(_ color: Color) {
        accentColor = color
        if let colorData = try? NSKeyedArchiver.archivedData(withRootObject: UIColor(color), requiringSecureCoding: false) {
            UserDefaults.standard.set(colorData, forKey: "accentColor")
        }
    }
} 