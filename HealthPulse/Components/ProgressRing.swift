import SwiftUI

/// 活动环风格的进度环 — 苹果原生风格
struct ProgressRing: View {
    var progress: Double // 0.0 - 1.0
    var color: Color
    var lineWidth: CGFloat = 12
    var showBackground: Bool = true

    var body: some View {
        ZStack {
            if showBackground {
                Circle()
                    .stroke(color.opacity(0.2), lineWidth: lineWidth)
            }

            Circle()
                .trim(from: 0, to: min(progress, 1.0))
                .stroke(
                    AngularGradient(
                        colors: [color, color.opacity(0.8)],
                        center: .center,
                        startAngle: .degrees(-90),
                        endAngle: .degrees(270)
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.6), value: progress)
        }
    }
}

/// 多环叠加（类似苹果活动圆环）
struct MultiProgressRing: View {
    struct RingData {
        let progress: Double
        let color: Color
        let label: String
    }

    let rings: [RingData]
    var lineWidth: CGFloat = 10

    var body: some View {
        ZStack {
            ForEach(Array(rings.enumerated()), id: \.offset) { index, ring in
                let inset = CGFloat(index) * (lineWidth + 4)
                ProgressRing(
                    progress: ring.progress,
                    color: ring.color,
                    lineWidth: lineWidth
                )
                .padding(inset)
            }
        }
    }
}

/// 带中心文字的进度环
struct LabeledProgressRing: View {
    var progress: Double
    var color: Color
    var lineWidth: CGFloat = 12
    var centerText: String
    var centerSubtext: String?

    var body: some View {
        ZStack {
            ProgressRing(progress: progress, color: color, lineWidth: lineWidth)

            VStack(spacing: 2) {
                Text(centerText)
                    .font(.hpMetric(20))
                    .foregroundStyle(.hpLabel)
                if let subtext = centerSubtext {
                    Text(subtext)
                        .font(.hpCaption2)
                        .foregroundStyle(.hpSecondaryLabel)
                }
            }
        }
    }
}

/// 水平进度条
struct HorizontalProgressBar: View {
    var progress: Double
    var color: Color
    var height: CGFloat = 8
    var backgroundColor: Color = .hpSecondaryFill

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(backgroundColor)
                    .frame(height: height)

                RoundedRectangle(cornerRadius: height / 2)
                    .fill(color)
                    .frame(width: geometry.size.width * min(progress, 1.0), height: height)
                    .animation(.easeInOut(duration: 0.4), value: progress)
            }
        }
        .frame(height: height)
    }
}

#Preview {
    VStack(spacing: 30) {
        HStack(spacing: 30) {
            LabeledProgressRing(
                progress: 0.75,
                color: .hpRed,
                centerText: "75%",
                centerSubtext: "活动"
            )
            .frame(width: 100, height: 100)

            MultiProgressRing(rings: [
                .init(progress: 0.8, color: .hpRed, label: "Move"),
                .init(progress: 0.6, color: .hpGreen, label: "Exercise"),
                .init(progress: 0.9, color: .hpBlue, label: "Stand")
            ])
            .frame(width: 120, height: 120)
        }

        HorizontalProgressBar(progress: 0.65, color: .hpGreen)
            .padding(.horizontal, 40)
    }
    .padding()
    .background(Color.hpGroupedBackground)
}
