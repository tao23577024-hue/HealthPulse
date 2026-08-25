import SwiftUI
import Charts

/// 仪表盘主页 — 苹果原生风格的健康概览
struct DashboardView: View {
    @EnvironmentObject var appState: AppState
    @State private var showRefreshAnimation = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 顶部问候和日期
                headerSection

                // 活动环概览
                activityRingsSection

                // 核心指标网格（2列）
                coreMetricsGrid

                // 心率和HRV
                heartSection

                // 睡眠概览
                sleepSection

                // 最近锻炼
                recentWorkoutsSection

                // 洞察
                insightsSection

                // 底部留白
                Color.clear.frame(height: 20)
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
        }
        .background(Color.hpGroupedBackground)
        .navigationTitle("概览")
        .navigationBarTitleDisplayMode(.large)
        .refreshable {
            await refreshData()
        }
        .overlay {
            if appState.isLoading {
                loadingOverlay
            }
        }
    }

    // MARK: - 顶部
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(greeting)
                    .font(.hpTitle2)
                    .fontWeight(.bold)
                    .foregroundStyle(.hpLabel)
                Text(dateString)
                    .font(.hpSubheadline)
                    .foregroundStyle(.hpSecondaryLabel)
            }
            Spacer()

            // 刷新按钮
            Button {
                Task { await refreshData() }
            } label: {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.hpAccent)
                    .rotationEffect(.degrees(showRefreshAnimation ? 360 : 0))
                    .animation(.linear(duration: 0.6), value: showRefreshAnimation)
            }
        }
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "早上好"
        case 12..<18: return "下午好"
        case 18..<22: return "晚上好"
        default: return "夜深了"
        }
    }

    private var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M月d日 EEEE"
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: Date())
    }

    // MARK: - 活动环
    private var activityRingsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(title: "活动", icon: "flame.fill", color: .hpRed)

            HStack(spacing: 20) {
                // 三环
                ZStack {
                    MultiProgressRing(rings: [
                        .init(progress: moveProgress, color: .hpRed, label: "Move"),
                        .init(progress: exerciseProgress, color: .hpGreen, label: "Exercise"),
                        .init(progress: standProgress, color: .hpBlue, label: "Stand")
                    ], lineWidth: 11)
                    .frame(width: 110, height: 110)

                    VStack(spacing: 2) {
                        Text("\(appState.steps.withComma)")
                            .font(.hpMetric(18))
                            .foregroundStyle(.hpLabel)
                        Text("步")
                            .font(.hpCaption2)
                            .foregroundStyle(.hpSecondaryLabel)
                    }
                }

                // 三项数据
                VStack(spacing: 10) {
                    activityRow(
                        color: .hpRed,
                        title: "活动能量",
                        value: "\(Int(appState.activeCalories))",
                        unit: "千卡",
                        goal: "\(Int(appState.dailyCalorieGoal)) 千卡"
                    )
                    activityRow(
                        color: .hpGreen,
                        title: "锻炼时间",
                        value: "\(Int(appState.exerciseMinutes))",
                        unit: "分钟",
                        goal: "30 分钟"
                    )
                    activityRow(
                        color: .hpBlue,
                        title: "站立",
                        value: "\(Int(appState.standHours))",
                        unit: "小时",
                        goal: "12 小时"
                    )
                }
            }
        }
        .padding(16)
        .background(Color.hpSecondaryGroupedBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var moveProgress: Double {
        guard appState.dailyCalorieGoal > 0 else { return 0 }
        return min(appState.activeCalories / appState.dailyCalorieGoal, 1.0)
    }

    private var exerciseProgress: Double {
        min(appState.exerciseMinutes / 30, 1.0)
    }

    private var standProgress: Double {
        min(appState.standHours / 12, 1.0)
    }

    private func activityRow(color: Color, title: String, value: String, unit: String, goal: String) -> some View {
        HStack(spacing: 8) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.hpCaption2)
                    .foregroundStyle(.hpSecondaryLabel)
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text(value)
                        .font(.hpMetric(16))
                        .foregroundStyle(.hpLabel)
                    Text(unit)
                        .font(.hpCaption2)
                        .foregroundStyle(.hpTertiaryLabel)
                    Text("/ \(goal)")
                        .font(.hpCaption2)
                        .foregroundStyle(.hpTertiaryLabel)
                }
            }
            Spacer()
        }
    }

    // MARK: - 核心指标网格
    private var coreMetricsGrid: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(title: "今日概览", icon: "chart.bar.fill", color: .hpAccent)

            LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                HealthMetricCard(
                    icon: "figure.run",
                    iconColor: .hpGreen,
                    title: "步数",
                    value: appState.steps.withComma,
                    progress: Double(appState.steps) / Double(appState.dailyStepGoal),
                    goal: "目标 \(appState.dailyStepGoal.withComma)",
                    chartData: appState.weeklySteps,
                    chartColor: .hpGreen
                )

                HealthMetricCard(
                    icon: "bed.double.fill",
                    iconColor: .hpIndigo,
                    title: "睡眠",
                    value: appState.sleepHours.asOneDecimalString,
                    unit: "小时",
                    progress: appState.sleepHours / appState.sleepGoalHours,
                    goal: "目标 \(appState.sleepGoalHours.asOneDecimalString)h",
                    chartData: appState.weeklySleep,
                    chartColor: .hpIndigo
                )

                HealthMetricCard(
                    icon: "flame.fill",
                    iconColor: .hpOrange,
                    title: "活动能量",
                    value: "\(Int(appState.activeCalories))",
                    unit: "千卡",
                    progress: appState.activeCalories / appState.dailyCalorieGoal,
                    goal: "目标 \(Int(appState.dailyCalorieGoal))",
                    chartData: appState.weeklyCalories,
                    chartColor: .hpOrange
                )

                HealthMetricCard(
                    icon: "clock.fill",
                    iconColor: .hpTeal,
                    title: "锻炼",
                    value: "\(Int(appState.exerciseMinutes))",
                    unit: "分钟",
                    progress: appState.exerciseMinutes / 30,
                    goal: "目标 30 分钟"
                )
            }
        }
    }

    // MARK: - 心率
    private var heartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(title: "心脏", icon: "heart.fill", color: .hpRed)

            HStack(spacing: 12) {
                // 当前心率
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 12))
                            .foregroundStyle(.hpRed)
                        Text("当前心率")
                            .font(.hpCaption)
                            .foregroundStyle(.hpSecondaryLabel)
                    }
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text("\(Int(appState.heartRate))")
                            .font(.hpMetric(36))
                            .foregroundStyle(.hpLabel)
                        Text("BPM")
                            .font(.hpCaption)
                            .foregroundStyle(.hpSecondaryLabel)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Divider()

                // 静息心率和HRV
                VStack(alignment: .leading, spacing: 8) {
                    heartMetricRow(title: "静息心率", value: "\(Int(appState.restingHeartRate))", unit: "BPM", color: .hpRed)
                    heartMetricRow(title: "心率变异性", value: "\(Int(appState.heartRateVariability))", unit: "ms", color: .hpPurple)
                    heartMetricRow(title: "血氧", value: appState.bloodOxygen > 0 ? "\(Int(appState.bloodOxygen))" : "--", unit: "%", color: .hpBlue)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            // 心率周趋势图
            if !appState.weeklyHeartRate.isEmpty {
                heartRateChart
            }
        }
        .padding(16)
        .background(Color.hpSecondaryGroupedBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func heartMetricRow(title: String, value: String, unit: String, color: Color) -> some View {
        HStack {
            Text(title)
                .font(.hpCaption)
                .foregroundStyle(.hpSecondaryLabel)
            Spacer()
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(value)
                    .font(.hpMetric(16))
                    .foregroundStyle(.hpLabel)
                Text(unit)
                    .font(.hpCaption2)
                    .foregroundStyle(.hpTertiaryLabel)
            }
        }
    }

    private var heartRateChart: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("本周心率趋势")
                .font(.hpCaption)
                .foregroundStyle(.hpSecondaryLabel)

            Chart(appState.weeklyHeartRate) { point in
                LineMark(
                    x: .value("日期", point.date, unit: .day),
                    y: .value("心率", point.value)
                )
                .foregroundStyle(Color.hpRed)
                .lineStyle(StrokeStyle(lineWidth: 2.5, lineCap: .round))

                AreaMark(
                    x: .value("日期", point.date, unit: .day),
                    y: .value("心率", point.value)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.hpRed.opacity(0.25), Color.hpRed.opacity(0.0)],
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
                        .foregroundStyle(Color.hpTertiaryLabel)
                }
            }
            .chartYAxis(.hidden)
            .frame(height: 100)
        }
    }

    // MARK: - 睡眠
    private var sleepSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(title: "睡眠", icon: "bed.double.fill", color: .hpIndigo)

            HStack(spacing: 16) {
                // 睡眠时长环
                LabeledProgressRing(
                    progress: appState.sleepHours / appState.sleepGoalHours,
                    color: .hpIndigo,
                    lineWidth: 10,
                    centerText: appState.sleepHours.asOneDecimalString,
                    centerSubtext: "小时"
                )
                .frame(width: 90, height: 90)

                // 睡眠阶段
                VStack(spacing: 6) {
                    sleepStageRow(stage: .deep, minutes: appState.deepSleepMinutes)
                    sleepStageRow(stage: .rem, minutes: appState.remSleepMinutes)
                    sleepStageRow(stage: .core, minutes: max(appState.sleepHours * 60 - appState.deepSleepMinutes - appState.remSleepMinutes, 0))
                    HStack {
                        Text("睡眠效率")
                            .font(.hpCaption)
                            .foregroundStyle(.hpSecondaryLabel)
                        Spacer()
                        Text("\(Int(appState.sleepEfficiency * 100))%")
                            .font(.hpCaption)
                            .fontWeight(.semibold)
                            .foregroundStyle(appState.sleepEfficiency >= 0.85 ? .hpGreen : .hpOrange)
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(16)
        .background(Color.hpSecondaryGroupedBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func sleepStageRow(stage: SleepStage, minutes: Double) -> some View {
        HStack(spacing: 6) {
            Circle()
                .fill(stage.color)
                .frame(width: 8, height: 8)
            Text(stage.displayName)
                .font(.hpCaption)
                .foregroundStyle(.hpSecondaryLabel)
            Spacer()
            Text(minutes.minutesToHourMinuteString)
                .font(.hpCaption)
                .fontWeight(.medium)
                .foregroundStyle(.hpLabel)
        }
    }

    // MARK: - 最近锻炼
    private var recentWorkoutsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(title: "最近锻炼", icon: "figure.run", color: .hpGreen)

            if appState.recentWorkouts.isEmpty {
                Text("暂无锻炼记录")
                    .font(.hpFootnote)
                    .foregroundStyle(.hpSecondaryLabel)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 16)
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(appState.recentWorkouts.prefix(3).enumerated()), id: \.element.id) { index, workout in
                        WorkoutRow(workout: workout)
                        if index < min(appState.recentWorkouts.count, 3) - 1 {
                            Divider()
                                .padding(.leading, 52)
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(Color.hpSecondaryGroupedBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    // MARK: - 洞察
    private var insightsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(title: "健康洞察", icon: "lightbulb.fill", color: .hpYellow)
            InsightsSection(insights: appState.insights)
        }
    }

    // MARK: - 辅助
    private func sectionHeader(title: String, icon: String, color: Color) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(color)
            Text(title)
                .font(.hpHeadline)
                .fontWeight(.semibold)
                .foregroundStyle(.hpLabel)
            Spacer()
        }
    }

    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.2)
                .ignoresSafeArea()
            ProgressView()
                .scaleEffect(1.2)
                .tint(.white)
        }
    }

    private func refreshData() async {
        withAnimation { showRefreshAnimation = true }
        appState.fetchAllHealthData()
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        withAnimation { showRefreshAnimation = false }
    }
}

/// 锻炼行
struct WorkoutRow: View {
    let workout: WorkoutRecord

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color.hpGreen.opacity(0.12))
                    .frame(width: 40, height: 40)
                Image(systemName: workout.type.systemImage)
                    .font(.system(size: 18))
                    .foregroundStyle(.hpGreen)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(workout.type.displayName)
                    .font(.hpSubheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.hpLabel)
                Text(workout.startDate.relativeTimeString)
                    .font(.hpCaption2)
                    .foregroundStyle(.hpTertiaryLabel)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(workout.durationString)
                    .font(.hpSubheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.hpLabel)
                HStack(spacing: 4) {
                    if let distance = workout.distance, distance > 0 {
                        Text(String(format: "%.1f公里", distance / 1000))
                            .font(.hpCaption2)
                            .foregroundStyle(.hpTertiaryLabel)
                    }
                    Text("\(Int(workout.calories))千卡")
                        .font(.hpCaption2)
                        .foregroundStyle(.hpTertiaryLabel)
                }
            }
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
    }
}

#Preview {
    NavigationStack {
        DashboardView()
            .environmentObject(AppState())
    }
}
