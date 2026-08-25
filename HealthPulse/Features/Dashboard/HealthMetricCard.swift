import SwiftUI
import Charts

/// 健康指标卡片 — 仪表盘上的核心数据展示
struct HealthMetricCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let value: String
    let unit: String?
    var subtitle: String?
    var progress: Double?
    var goal: String?
    var trend: HealthMetricRow.TrendDirection?
    var trendValue: String?
    var chartData: [DailyMetric]?
    var chartColor: Color?
    var onTap: (() -> Void)?

    var body: some View {
        Button(action: { onTap?() }) {
            VStack(alignment: .leading, spacing: 10) {
                // 头部
                HStack(spacing: 6) {
                    Image(systemName: icon)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(iconColor)
                    Text(title)
                        .font(.hpFootnote)
                        .fontWeight(.medium)
                        .foregroundStyle(.hpSecondaryLabel)
                    Spacer()
                    if let trend = trend, let trendValue = trendValue {
                        HStack(spacing: 2) {
                            Image(systemName: trend.icon)
                                .font(.system(size: 9, weight: .bold))
                            Text(trendValue)
                                .font(.system(size: 10, weight: .semibold))
                        }
                        .foregroundStyle(trend.color)
                    }
                }

                // 数值
                HStack(alignment: .firstTextBaseline, spacing: 3) {
                    Text(value)
                        .font(.hpMetric(28))
                        .foregroundStyle(.hpLabel)
                        .minimumScaleFactor(0.7)
                        .lineLimit(1)
                    if let unit = unit {
                        Text(unit)
                            .font(.hpCaption)
                            .foregroundStyle(.hpSecondaryLabel)
                    }
                }

                // 副标题/目标
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.hpCaption2)
                        .foregroundStyle(.hpTertiaryLabel)
                        .lineLimit(1)
                }

                // 进度条
                if let progress = progress {
                    VStack(spacing: 4) {
                        HorizontalProgressBar(progress: progress, color: iconColor, height: 6)
                        if let goal = goal {
                            HStack {
                                Text(goal)
                                    .font(.hpCaption2)
                                    .foregroundStyle(.hpTertiaryLabel)
                                Spacer()
                                Text("\(Int(progress * 100))%")
                                    .font(.hpCaption2)
                                    .foregroundStyle(.hpTertiaryLabel)
                            }
                        }
                    }
                }

                // 迷你图表
                if let chartData = chartData, !chartData.isEmpty {
                    MiniChart(data: chartData, color: chartColor ?? iconColor)
                        .frame(height: 36)
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.hpSecondaryGroupedBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

/// 迷你折线图
struct MiniChart: View {
    let data: [DailyMetric]
    let color: Color

    var body: some View {
        Chart(data) { point in
            LineMark(
                x: .value("日期", point.date),
                y: .value("值", point.value)
            )
            .foregroundStyle(color)
            .lineStyle(StrokeStyle(lineWidth: 2, lineCap: .round))

            AreaMark(
                x: .value("日期", point.date),
                y: .value("值", point.value)
            )
            .foregroundStyle(
                LinearGradient(
                    colors: [color.opacity(0.3), color.opacity(0.0)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
        .chartPlotStyle { plotArea in
            plotArea
                .background(Color.clear)
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        HealthMetricCard(
            icon: "heart.fill",
            iconColor: .hpRed,
            title: "心率",
            value: "72",
            unit: "BPM",
            subtitle: "当前 · 静息 62",
            trend: .down,
            trendValue: "3%",
            chartData: PreviewData.shared.weeklyHeartRate,
            chartColor: .hpRed
        )

        HStack(spacing: 12) {
            HealthMetricCard(
                icon: "figure.run",
                iconColor: .hpGreen,
                title: "步数",
                value: "8,432",
                progress: 0.84,
                goal: "目标 10,000",
                chartData: PreviewData.shared.weeklySteps,
                chartColor: .hpGreen
            )
            HealthMetricCard(
                icon: "bed.double.fill",
                iconColor: .hpIndigo,
                title: "睡眠",
                value: "7.2",
                unit: "小时",
                progress: 0.9,
                goal: "目标 8h",
                chartData: PreviewData.shared.weeklySleep,
                chartColor: .hpIndigo
            )
        }
    }
    .padding()
    .background(Color.hpGroupedBackground)
}
