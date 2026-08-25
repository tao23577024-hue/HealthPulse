import SwiftUI

/// 健康指标行 — 用于列表展示
struct HealthMetricRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let value: String
    var unit: String?
    var subtitle: String?
    var trend: TrendDirection?
    var trendValue: String?

    enum TrendDirection {
        case up
        case down
        case flat

        var icon: String {
            switch self {
            case .up: return "arrow.up.right"
            case .down: return "arrow.down.right"
            case .flat: return "minus"
            }
        }

        var color: Color {
            switch self {
            case .up: return .hpGreen
            case .down: return .hpRed
            case .flat: return .hpGray
            }
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            // 图标
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(iconColor)
            }

            // 标题和副标题
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.hpBody)
                    .foregroundStyle(.hpLabel)
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.hpCaption)
                        .foregroundStyle(.hpSecondaryLabel)
                }
            }

            Spacer()

            // 趋势
            if let trend = trend, let trendValue = trendValue {
                HStack(spacing: 2) {
                    Image(systemName: trend.icon)
                        .font(.system(size: 10, weight: .semibold))
                    Text(trendValue)
                        .font(.hpCaption2)
                }
                .foregroundStyle(trend.color)
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(trend.color.opacity(0.1))
                .clipShape(Capsule())
            }

            // 数值
            VStack(alignment: .trailing, spacing: 1) {
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text(value)
                        .font(.hpMetric(18))
                        .foregroundStyle(.hpLabel)
                    if let unit = unit {
                        Text(unit)
                            .font(.hpCaption2)
                            .foregroundStyle(.hpSecondaryLabel)
                    }
                }
            }

            Image(systemName: "chevron.right")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.hpTertiaryLabel)
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
    }
}

/// 简单指标行（无图标）
struct SimpleMetricRow: View {
    let title: String
    let value: String
    var valueColor: Color = .hpLabel

    var body: some View {
        HStack {
            Text(title)
                .font(.hpBody)
                .foregroundStyle(.hpSecondaryLabel)
            Spacer()
            Text(value)
                .font(.hpBody)
                .fontWeight(.medium)
                .foregroundStyle(valueColor)
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    List {
        HealthMetricRow(
            icon: "heart.fill",
            iconColor: .hpRed,
            title: "心率",
            value: "72",
            unit: "BPM",
            subtitle: "当前",
            trend: .down,
            trendValue: "3%"
        )
        HealthMetricRow(
            icon: "bed.double.fill",
            iconColor: .hpIndigo,
            title: "睡眠",
            value: "7.2",
            unit: "小时",
            subtitle: "昨晚",
            trend: .up,
            trendValue: "0.5h"
        )
        HealthMetricRow(
            icon: "figure.run",
            iconColor: .hpGreen,
            title: "步数",
            value: "8,432",
            subtitle: "今日",
            trend: .flat,
            trendValue: "0%"
        )
    }
}
