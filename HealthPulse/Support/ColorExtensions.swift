import SwiftUI

// MARK: - 应用主题颜色 — 苹果原生风格配色
extension Color {
    // 主色调
    static let hpAccent = Color(red: 0.0, green: 0.478, blue: 1.0) // 苹果蓝 #007AFF

    // 功能色
    static let hpBlue = Color(red: 0.0, green: 0.478, blue: 1.0)
    static let hpGreen = Color(red: 0.204, green: 0.780, blue: 0.349) // #34C759
    static let hpOrange = Color(red: 1.0, green: 0.584, blue: 0.0) // #FF9500
    static let hpRed = Color(red: 1.0, green: 0.231, blue: 0.188) // #FF3B30
    static let hpPurple = Color(red: 0.686, green: 0.322, blue: 0.871) // #AF52DE
    static let hpPink = Color(red: 1.0, green: 0.176, blue: 0.333) // #FF2D55
    static let hpTeal = Color(red: 0.235, green: 0.729, blue: 0.824) // #3CC2D2
    static let hpIndigo = Color(red: 0.345, green: 0.337, blue: 0.839) // #5856D6
    static let hpYellow = Color(red: 1.0, green: 0.800, blue: 0.0) // #FFCC00
    static let hpGray = Color(red: 0.557, green: 0.557, blue: 0.576) // #8E8E93

    // 语义背景色（适配深色模式）
    static var hpBackground: Color {
        Color(uiColor: .systemBackground)
    }
    static var hpSecondaryBackground: Color {
        Color(uiColor: .secondarySystemBackground)
    }
    static var hpTertiaryBackground: Color {
        Color(uiColor: .tertiarySystemBackground)
    }
    static var hpGroupedBackground: Color {
        Color(uiColor: .systemGroupedBackground)
    }
    static var hpSecondaryGroupedBackground: Color {
        Color(uiColor: .secondarySystemGroupedBackground)
    }

    // 语义文字色
    static var hpLabel: Color {
        Color(uiColor: .label)
    }
    static var hpSecondaryLabel: Color {
        Color(uiColor: .secondaryLabel)
    }
    static var hpTertiaryLabel: Color {
        Color(uiColor: .tertiaryLabel)
    }

    // 分隔线
    static var hpSeparator: Color {
        Color(uiColor: .separator)
    }
    static var hpOpaqueSeparator: Color {
        Color(uiColor: .opaqueSeparator)
    }

    // 填充色
    static var hpFill: Color {
        Color(uiColor: .systemFill)
    }
    static var hpSecondaryFill: Color {
        Color(uiColor: .secondarySystemFill)
    }
    static var hpTertiaryFill: Color {
        Color(uiColor: .tertiarySystemFill)
    }
}

// MARK: - 渐变
extension LinearGradient {
    static let hpBlueGradient = LinearGradient(
        colors: [Color(red: 0.0, green: 0.478, blue: 1.0), Color(red: 0.235, green: 0.729, blue: 0.824)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let hpGreenGradient = LinearGradient(
        colors: [Color(red: 0.204, green: 0.780, blue: 0.349), Color(red: 0.235, green: 0.729, blue: 0.824)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let hpPurpleGradient = LinearGradient(
        colors: [Color(red: 0.686, green: 0.322, blue: 0.871), Color(red: 0.345, green: 0.337, blue: 0.839)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let hpOrangeGradient = LinearGradient(
        colors: [Color(red: 1.0, green: 0.584, blue: 0.0), Color(red: 1.0, green: 0.231, blue: 0.188)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let hpSleepGradient = LinearGradient(
        colors: [Color(red: 0.345, green: 0.337, blue: 0.839), Color(red: 0.110, green: 0.110, blue: 0.280)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// MARK: - 字体扩展
extension Font {
    static func hpMetric(_ size: CGFloat) -> Font {
        .system(size: size, weight: .semibold, design: .rounded)
    }

    static func hpMetricLabel(_ size: CGFloat) -> Font {
        .system(size: size, weight: .medium, design: .default)
    }

    static let hpLargeTitle = Font.system(size: 34, weight: .bold, design: .default)
    static let hpTitle1 = Font.system(size: 28, weight: .bold, design: .default)
    static let hpTitle2 = Font.system(size: 22, weight: .semibold, design: .default)
    static let hpTitle3 = Font.system(size: 20, weight: .semibold, design: .default)
    static let hpHeadline = Font.system(size: 17, weight: .semibold, design: .default)
    static let hpBody = Font.system(size: 17, weight: .regular, design: .default)
    static let hpCallout = Font.system(size: 16, weight: .regular, design: .default)
    static let hpSubheadline = Font.system(size: 15, weight: .regular, design: .default)
    static let hpFootnote = Font.system(size: 13, weight: .regular, design: .default)
    static let hpCaption = Font.system(size: 12, weight: .regular, design: .default)
    static let hpCaption2 = Font.system(size: 11, weight: .regular, design: .default)
}

// MARK: - View 扩展
extension View {
    /// 苹果风格卡片背景
    func hpCardStyle() -> some View {
        self
            .background(Color.hpSecondaryGroupedBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    /// 毛玻璃背景
    func hpGlassBackground() -> some View {
        self
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    /// 隐藏列表分隔线
    func hpHideListSeparator() -> some View {
        self
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
    }

    /// 数字等宽字体
    func hpMonospacedDigit() -> some View {
        self.monospacedDigit()
    }
}
