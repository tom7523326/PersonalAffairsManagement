import SwiftUI

// MARK: - 设计系统
struct DesignSystem {
    
    // MARK: - 颜色系统
    struct Colors {
        // 主色调
        static let primary = Color.blue
        static let primaryLight = Color.blue.opacity(0.1)
        static let primaryDark = Color.blue.opacity(0.8)
        
        // 辅助色
        static let secondary = Color.gray
        static let accent = Color.orange
        
        // 语义色
        static let success = Color.green
        static let warning = Color.yellow
        static let error = Color.red
        static let info = Color.blue
        
        // 中性色
        static let background = Color(.systemBackground)
        static let secondaryBackground = Color(.secondarySystemBackground)
        static let tertiaryBackground = Color(.tertiarySystemBackground)
        
        static let text = Color(.label)
        static let secondaryText = Color(.secondaryLabel)
        static let tertiaryText = Color(.tertiaryLabel)
        
        // 边框和分割线
        static let border = Color(.separator)
        static let divider = Color(.opaqueSeparator)
        
        // 卡片背景
        static let cardBackground = Color(.systemBackground)
        static let cardShadow = Color.black.opacity(0.1)
    }
    
    // MARK: - 字体系统
    struct Typography {
        // 标题字体
        static let largeTitle = Font.largeTitle.weight(.bold)
        static let title1 = Font.title.weight(.bold)
        static let title2 = Font.title2.weight(.semibold)
        static let title3 = Font.title3.weight(.semibold)
        
        // 正文字体
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
    }
    
    // MARK: - 间距系统
    struct Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }
    
    // MARK: - 圆角系统
    struct CornerRadius {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 24
        static let full: CGFloat = 999
    }
    
    // MARK: - 阴影系统
    struct Shadows {
        static let small = Shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        static let medium = Shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
        static let large = Shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
    }
    
    // MARK: - 动画系统
    struct Animation {
        static let quick = SwiftUI.Animation.easeInOut(duration: 0.2)
        static let standard = SwiftUI.Animation.easeInOut(duration: 0.3)
        static let slow = SwiftUI.Animation.easeInOut(duration: 0.5)
        static let spring = SwiftUI.Animation.spring(response: 0.5, dampingFraction: 0.8)
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
    // 应用卡片样式
    func cardStyle() -> some View {
        self
            .background(DesignSystem.Colors.cardBackground)
            .cornerRadius(DesignSystem.CornerRadius.md)
            .shadow(
                color: DesignSystem.Shadows.small.color,
                radius: DesignSystem.Shadows.small.radius,
                x: DesignSystem.Shadows.small.x,
                y: DesignSystem.Shadows.small.y
            )
    }
    
    // 应用主要按钮样式
    func primaryButtonStyle() -> some View {
        self
            .font(DesignSystem.Typography.headline)
            .foregroundColor(.white)
            .padding(.horizontal, DesignSystem.Spacing.lg)
            .padding(.vertical, DesignSystem.Spacing.md)
            .background(DesignSystem.Colors.primary)
            .cornerRadius(DesignSystem.CornerRadius.md)
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
    }
    
    // 应用输入框样式
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
}

// MARK: - 预定义颜色资源
extension Color {
    static let systemPrimary = Color.blue
    static let systemSecondary = Color.gray
    static let systemBackground = Color(.systemBackground)
    static let systemCardBackground = Color(.systemBackground)
} 