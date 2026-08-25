import SwiftUI
import Charts

/// 睡眠详情页 — 睡眠阶段可视化、周趋势、睡眠评分
struct SleepView: View {
    @EnvironmentObject var appState: AppState
    @State private var timeRange: Int = 1

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 睡眠评分和时长
                sleepScoreSection

                // 睡眠阶段时间线
                if !appState.sleepStages.isEmpty {
                    sleepStagesSection
                }

                // 睡眠阶段统计
                sleepStageStatsSection

                // 周趋势
                sleepTrendSection

                // 睡眠建议
                sleepTipsSection
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
        }
        .background(Color.hpGroupedBackground)
        .navigationTitle("睡眠")
        .navigationBarTitleDisplayMode(.large)
    }

    // MARK: - 睡眠评分
    private var sleepScoreSection: some View {
        VStack(spacing: 16) {
            HStack(spacing: 20) {
                // 睡眠评分环
                ZStack {
                    ProgressRing(
                        progress: sleepScore / 100,
                        color: sleepScoreColor,
                        lineWidth: 12
                    )
                    .frame(width: 110, height: 110)

                    VStack(spacing: 2) {
                        Text("\(Int(sleepScore))")
                            .font(.hpMetric(32))
                            .foregroundStyle(.hpLabel)
                        Text("睡眠评分")
                            .font(.hpCaption2)
                            .foregroundStyle(.hpSecondaryLabel)
                    }
                }

                // 睡眠数据
                VStack(spacing: 10) {
                    sleepDataRow(title: "总睡眠", value: appState.sleepHours.hoursToHourMinuteString, icon: "moon.fill")
                    sleepDataRow(title: "深睡", value: appState.deepSleepMinutes.minutesToHourMinuteString, icon: "moon.stars.fill")
                    sleepDataRow(title: "REM", value: appState.remSleepMinutes.minutesToHourMinuteString, icon: "eye.fill")
                    sleepDataRow(title: "睡眠效率", value: "\(Int(appState.sleepEfficiency * 100))%", icon: "percent")
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(16)
        .background(
            LinearGradient(
                colors: [Color.hpIndigo.opacity(0.15), Color.hpSecondaryGroupedBackground],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var sleepScore: Double {
        // 睡眠时长 50% + 深睡比例 30% + 睡眠效率 20%
        let durationScore = min(appState.sleepHours / appState.sleepGoalHours, 1.0) * 50
        let totalMinutes = appState.sleepHours * 60
        let deepRatio = totalMinutes > 0 ? appState.deepSleepMinutes / totalMinutes : 0
        let deepScore = min(deepRatio / 0.2, 1.0) * 30 // 目标深睡20%
        let efficiencyScore = min(appState.sleepEfficiency / 0.9, 1.0) * 20
        return durationScore + deepScore + efficiencyScore
    }

    private var sleepScoreColor: Color {
        switch sleepScore {
        case 80...100: return .hpGreen
        case 60..<80: return .hpBlue
        case 40..<60: return .hpOrange
        default: return .hpRed
        }
    }

    private func sleepDataRow(title: String, value: String, icon: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundStyle(.hpIndigo)
            Text(title)
                .font(.hpCaption)
                .foregroundStyle(.hpSecondaryLabel)
            Spacer()
            Text(value)
                .font(.hpSubheadline)
                .fontWeight(.medium)
                .foregroundStyle(.hpLabel)
        }
    }

    // MARK: - 睡眠阶段时间线
    private var sleepStagesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("睡眠阶段")
                .font(.hpHeadline)
                .fontWeight(.semibold)

            // 时间轴
            SleepTimelineView(stages: appState.sleepStages)
                .frame(height: 80)

            // 图例
            HStack(spacing: 12) {
                ForEach([SleepStage.deep, .rem, .core, .awake]) { stage in
                    HStack(spacing: 4) {
                        Circle()
                            .fill(stage.color)
                            .frame(width: 8, height: 8)
                        Text(stage.displayName)
                            .font(.hpCaption2)
                            .foregroundStyle(.hpSecondaryLabel)
                    }
                }
            }
        }
        .padding(16)
        .background(Color.hpSecondaryGroupedBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    // MARK: - 睡眠阶段统计
    private var sleepStageStatsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("阶段详情")
                .font(.hpHeadline)
                .fontWeight(.semibold)

            VStack(spacing: 0) {
                stageDetailRow(stage: .deep, minutes: appState.deepSleepMinutes, total: appState.sleepHours * 60)
                Divider().padding(.leading, 12)
                stageDetailRow(stage: .rem, minutes: appState.remSleepMinutes, total: appState.sleepHours * 60)
                Divider().padding(.leading, 12)
                let coreMinutes = max(appState.sleepHours * 60 - appState.deepSleepMinutes - appState.remSleepMinutes, 0)
                stageDetailRow(stage: .core, minutes: coreMinutes, total: appState.sleepHours * 60)
            }
        }
        .padding(16)
        .background(Color.hpSecondaryGroupedBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func stageDetailRow(stage: SleepStage, minutes: Double, total: Double) -> some View {
        let percentage = total > 0 ? minutes / total : 0
        return HStack(spacing: 12) {
            Circle()
                .fill(stage.color)
                .frame(width: 10, height: 10)
            Text(stage.displayName)
                .font(.hpBody)
                .foregroundStyle(.hpLabel)
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text(minutes.minutesToHourMinuteString)
                    .font(.hpBody)
                    .fontWeight(.medium)
                    .foregroundStyle(.hpLabel)
                Text("\(Int(percentage * 100))%")
                    .font(.hpCaption2)
                    .foregroundStyle(.hpTertiaryLabel)
            }
        }
        .padding(.vertical, 8)
    }

    // MARK: - 周趋势
    private var sleepTrendSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("本周睡眠趋势")
                .font(.hpHeadline)
                .fontWeight(.semibold)

            if !appState.weeklySleep.isEmpty {
                Chart(appState.weeklySleep) { point in
                    BarMark(
                        x: .value("日期", point.date, unit: .day),
                        y: .value("睡眠", point.value)
                    )
                    .foregroundStyle(
                        point.value >= appState.sleepGoalHours ? Color.hpGreen : Color.hpIndigo
                    )
                    .cornerRadius(4)

                    RuleMark(y: .value("目标", appState.sleepGoalHours))
                        .foregroundStyle(Color.hpSecondaryLabel.opacity(0.5))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))
                }
                .chartXAxis {
                    AxisMarks(position: .bottom, values: .stride(by: .day)) { value in
                        AxisValueLabel(format: .dateTime.weekday(.narrow))
                            .font(.hpCaption2)
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisGridLine().foregroundStyle(Color.hpSeparator.opacity(0.2))
                        AxisValueLabel()
                            .font(.hpCaption2)
                    }
                }
                .frame(height: 180)
            }
        }
        .padding(16)
        .background(Color.hpSecondaryGroupedBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    // MARK: - 睡眠建议
    private var sleepTipsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(.hpYellow)
                Text("睡眠建议")
                    .font(.hpHeadline)
                    .fontWeight(.semibold)
            }

            VStack(alignment: .leading, spacing: 10) {
                tipRow(icon: "moon.zzz.fill", text: "保持规律的作息时间，每天同一时间入睡和起床")
                tipRow(icon: "sun.max.fill", text: "白天多接触自然光，帮助调节生物钟")
                tipRow(icon: "cup.and.saucer.fill", text: "睡前 4-6 小时避免咖啡因摄入")
                tipRow(icon: "iphone.gen3.slash", text: "睡前 1 小时减少屏幕使用，蓝光会抑制褪黑素")
                tipRow(icon: "thermometer.medium", text: "保持卧室凉爽，理想温度 18-20°C")
                tipRow(icon: "wineglass", text: "睡前避免饮酒，酒精会减少深睡和REM睡眠")
            }
        }
        .padding(16)
        .background(Color.hpSecondaryGroupedBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func tipRow(icon: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(.hpIndigo)
                .frame(width: 20)
            Text(text)
                .font(.hpFootnote)
                .foregroundStyle(.hpSecondaryLabel)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

/// 睡眠阶段时间线可视化
struct SleepTimelineView: View {
    let stages: [SleepStageSample]

    var body: some View {
        GeometryReader { geometry in
            let totalDuration = stages.reduce(0) { $0 + $1.endDate.timeIntervalSince($1.startDate) }
            guard totalDuration > 0 else { return AnyView(EmptyView()) }

            var currentX: CGFloat = 0
            let height = geometry.size.height

            return AnyView(
                HStack(spacing: 0) {
                    ForEach(stages) { stage in
                        let duration = stage.endDate.timeIntervalSince(stage.startDate)
                        let width = geometry.size.width * CGFloat(duration / totalDuration)
                        Rectangle()
                            .fill(stage.stage.color)
                            .frame(width: width, height: height * 0.6)
                    }
                }
                .cornerRadius(6)
            )
        }
    }
}

#Preview {
    NavigationStack {
        SleepView()
            .environmentObject(AppState())
    }
}
