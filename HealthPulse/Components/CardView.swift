import SwiftUI

/// 苹果风格卡片容器
struct CardView<Content: View>: View {
    var content: Content
    var padding: CGFloat = 16
    var cornerRadius: CGFloat = 16
    var backgroundColor: Color = .hpSecondaryGroupedBackground

    init(padding: CGFloat = 16, cornerRadius: CGFloat = 16,
         backgroundColor: Color = .hpSecondaryGroupedBackground,
         @ViewBuilder content: () -> Content) {
        self.padding = padding
        self.cornerRadius = cornerRadius
        self.backgroundColor = backgroundColor
        self.content = content()
    }

    var body: some View {
        content
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
}

/// 可点击的卡片
struct TappableCardView<Content: View>: View {
    var action: () -> Void
    var content: Content
    var padding: CGFloat = 16

    init(action: @escaping () -> Void, padding: CGFloat = 16, @ViewBuilder content: () -> Content) {
        self.action = action
        self.padding = padding
        self.content = content()
    }

    var body: some View {
        Button(action: action) {
            content
                .padding(padding)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.hpSecondaryGroupedBackground)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

/// 带图标的标题行
struct CardHeader: View {
    let icon: String
    let title: String
    var iconColor: Color = .hpAccent
    var trailing: AnyView?

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(iconColor)
            Text(title)
                .font(.hpSubheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.hpSecondaryLabel)
            Spacer()
            if let trailing = trailing {
                trailing
            } else {
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.hpTertiaryLabel)
            }
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        CardView {
            CardHeader(icon: "heart.fill", title: "心率", iconColor: .hpRed)
            Spacer().frame(height: 8)
            Text("72 BPM")
                .font(.hpMetric(32))
        }

        TappableCardView {
            print("tapped")
        } content: {
            CardHeader(icon: "bed.double.fill", title: "睡眠", iconColor: .hpIndigo)
            Spacer().frame(height: 8)
            Text("7.2 小时")
                .font(.hpMetric(32))
        }
    }
    .padding()
    .background(Color.hpGroupedBackground)
}
