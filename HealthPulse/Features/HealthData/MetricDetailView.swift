import SwiftUI
import Charts

/// 健康指标详情页 — 展示详细数据和趋势图表
struct MetricDetailView: View {
    @EnvironmentObject var appState: AppState
    let metricType: HealthDataView.MetricType
    @State private var timeRange: Int = 1 // 0=日, 1=周, 2=月
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 大数值展示
                    bigValueSection

                    // 时间范围选择
                    timeRangeSelector

                    // 图表
                    chartSection

                    // 统计信息
                    statsSection

                    // 说明
                    infoSection
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }
            .background(Color.hpGroupedBackground)
            .navigationTitle(metricType.rawValue)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") { dismiss() }
                        .fontWeight(.semibold)
                }
            }
        }
    }

    // MARK: - 大数值
    private var bigValueSection: some View {
        VStack(spacing: 8) {
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(currentValue)
                    .font(.system(size: 56, weight: .bold, design: .rounded))
                    .foregroundStyle(metricType.color)
                if let unit = unitText {
                    Text(unit)
                        .font(.hpTitle3)
                        .foregroundStyle(.hpSecondaryLabel)
                }
            }

            HStack(spacing: 4) {
                Image(systemName: metricType.icon)
                    .font(.system(size: 12))
                Text(subtitleText)
                    .font(.hpFootnote)
            }
            .foregroundStyle(.hpSecondaryLabel)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(Color.hpSecondaryGroupedBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var currentValue: String {
        switch metricType {
        case .heartRate: return "\(Int(appState.heartRate))"
        case .restingHeartRate: return "\(Int(appState.restingHeartRate))"
        case .hrv: return "\(Int(appState.heartRateVariability))"
        case .bloodOxygen: return appState.bloodOxygen > 0 ? "\(Int(appState.bloodOxygen))" : "--"
        case .steps: return appState.steps.withComma
        case .activeCalories: return "\(Int(appState.activeCalories))"
        case .exerciseMinutes: return "\(Int(appState.exerciseMinutes))"
        case .standHours: return "\(Int(appState.standHours))"
        case .sleep: return appState.sleepHours.asOneDecimalString
        case .bodyWeight: return appState.bodyWeight > 0 ? appState.bodyWeight.asOneDecimalString : "--"
        case .bodyFat: return appState.bodyFatPercentage > 0 ? appState.bodyFatPercentage.asOneDecimalString : "--"
        case .vo2Max: return appState.vo2Max > 0 ? appState.vo2Max.asOneDecimalString : "--"
        }
    }

    private var unitText: String? {
        switch metricType {
        case .heartRate, .restingHeartRate: return "BPM"
        case .hrv: return "ms"
        case .bloodOxygen: return "%"
        case .activeCalories: return "千卡"
        case .exerciseMinutes: return "分钟"
        case .standHours: return "小时"
        case .sleep: return "小时"
        case .bodyWeight: return "kg"
        case .bodyFat: return "%"
        case .vo2Max: return "ml/kg·min"
        default: return nil
        }
    }

    private var subtitleText: String {
        switch metricType {
        case .heartRate: return "当前心率"
        case .restingHeartRate: return "今日静息心率"
        case .hrv: return "心率变异性 (SDNN)"
        case .bloodOxygen: return "血氧饱和度"
        case .steps: return "今日步数"
        case .activeCalories: return "今日活动能量"
        case .exerciseMinutes: return "今日锻炼时间"
        case .standHours: return "今日站立小时"
        case .sleep: return "昨晚睡眠时长"
        case .bodyWeight: return "最新体重"
        case .bodyFat: return "最新体脂率"
        case .vo2Max: return "心肺适能 (VO₂ Max)"
        }
    }

    // MARK: - 时间范围
    private var timeRangeSelector: some View {
        SegmentedControl(selectedIndex: $timeRange, items: ["日", "周", "月"])
    }

    // MARK: - 图表
    private var chartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("趋势")
                .font(.hpHeadline)
                .fontWeight(.semibold)

            if let data = chartData, !data.isEmpty {
                Chart(data) { point in
                    LineMark(
                        x: .value("日期", point.date, unit: .day),
                        y: .value("值", point.value)
                    )
                    .foregroundStyle(metricType.color)
                    .lineStyle(StrokeStyle(lineWidth: 2.5, lineCap: .round))

                    AreaMark(
                        x: .value("日期", point.date, unit: .day),
                        y: .value("值", point.value)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [metricType.color.opacity(0.25), metricType.color.opacity(0.0)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                }
                .chartXAxis {
                    AxisMarks(position: .bottom, values: .stride(by: .day)) { value in
                        AxisGridLine().foregroundStyle(Color.hpSeparator.opacity(0.3))
                        AxisValueLabel(format: .dateTime.weekday(.narrow))
                            .font(.hpCaption2)
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisGridLine().foregroundStyle(Color.hpSeparator.opacity(0.2))
                        AxisValueLabel()
                            .font(.hpCaption2)
                            .foregroundStyle(Color.hpTertiaryLabel)
                    }
                }
                .frame(height: 200)
            } else {
                Text("暂无足够数据展示趋势")
                    .font(.hpFootnote)
                    .foregroundStyle(.hpSecondaryLabel)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
            }
        }
        .padding(16)
        .background(Color.hpSecondaryGroupedBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var chartData: [DailyMetric]? {
        switch metricType {
        case .heartRate, .restingHeartRate: return appState.weeklyHeartRate
        case .hrv: return appState.weeklyHRV
        case .steps: return appState.weeklySteps
        case .activeCalories: return appState.weeklyCalories
        case .sleep: return appState.weeklySleep
        default: return nil
        }
    }

    // MARK: - 统计
    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("统计")
                .font(.hpHeadline)
                .fontWeight(.semibold)

            if let data = chartData, !data.isEmpty {
                let values = data.map { $0.value }.filter { $0 > 0 }
                if !values.isEmpty {
                    let avg = values.reduce(0, +) / Double(values.count)
                    let max = values.max() ?? 0
                    let min = values.min() ?? 0

                    VStack(spacing: 0) {
                        statRow(title: "平均值", value: formatStat(avg))
                        Divider().padding(.leading, 12)
                        statRow(title: "最高值", value: formatStat(max))
                        Divider().padding(.leading, 12)
                        statRow(title: "最低值", value: formatStat(min))
                    }
                }
            }
        }
        .padding(16)
        .background(Color.hpSecondaryGroupedBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func statRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.hpBody)
                .foregroundStyle(.hpSecondaryLabel)
            Spacer()
            Text(value)
                .font(.hpBody)
                .fontWeight(.medium)
                .foregroundStyle(.hpLabel)
        }
        .padding(.vertical, 8)
    }

    private func formatStat(_ value: Double) -> String {
        switch metricType {
        case .steps: return Int(value).withComma
        case .heartRate, .restingHeartRate, .hrv, .bloodOxygen,
             .activeCalories, .exerciseMinutes, .standHours:
            return "\(Int(value))"
        default: return value.asOneDecimalString
        }
    }

    // MARK: - 说明
    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "info.circle.fill")
                    .font(.system(size: 13))
                    .foregroundStyle(.hpBlue)
                Text("关于 \(metricType.rawValue)")
                    .font(.hpSubheadline)
                    .fontWeight(.semibold)
            }

            Text(infoText)
                .font(.hpFootnote)
                .foregroundStyle(.hpSecondaryLabel)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .background(Color.hpSecondaryGroupedBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var infoText: String {
        switch metricType {
        case .heartRate:
            return "心率是指心脏每分钟跳动的次数。正常静息心率范围通常为 60-100 BPM。经常运动的人静息心率可能更低。"
        case .restingHeartRate:
            return "静息心率是指在清醒、安静状态下的心率。持续升高的静息心率可能与压力、疾病或睡眠不足有关。"
        case .hrv:
            return "心率变异性 (HRV) 反映心跳间隔的变化程度。较高的 HRV 通常表示较好的自主神经平衡和恢复状态。"
        case .bloodOxygen:
            return "血氧饱和度反映血液中氧气的含量。正常范围通常为 95%-100%。持续低于 90% 可能需要就医。"
        case .steps:
            return "每日步数是衡量日常活动量的简单指标。一般建议每天至少 10,000 步，但任何增加活动量的改变都有益健康。"
        case .activeCalories:
            return "活动能量是指除基础代谢外，通过身体活动消耗的卡路里。"
        case .exerciseMinutes:
            return "锻炼时间指进行中等或更高强度活动的分钟数。WHO 建议每周至少 150 分钟中等强度活动。"
        case .standHours:
            return "站立小时数指每天至少站立活动 1 分钟的小时数。建议每小时起身活动，减少久坐时间。"
        case .sleep:
            return "睡眠对身体恢复、记忆巩固和免疫功能至关重要。成年人推荐每晚 7-9 小时睡眠。"
        case .bodyWeight:
            return "体重是整体健康的一个指标，但应结合体脂率、肌肉量和腰围等综合评估。"
        case .bodyFat:
            return "体脂率反映身体脂肪占总体重的比例。男性健康范围通常为 10-20%，女性为 18-28%。"
        case .vo2Max:
            return "VO₂ Max 是最大摄氧量，反映心肺适能水平。较高的 VO₂ Max 与心血管健康和长寿相关。"
        }
    }
}
