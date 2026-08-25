import SwiftUI
import Charts

/// 健身页面 — 锻炼记录、活动统计、周趋势
struct FitnessView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedFilter: WorkoutType? = nil
    @State private var showWorkoutDetail: WorkoutRecord?

    var filteredWorkouts: [WorkoutRecord] {
        if let filter = selectedFilter {
            return appState.recentWorkouts.filter { $0.type == filter }
        }
        return appState.recentWorkouts
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 今日活动概览
                todayActivitySection

                // 本周活动趋势
                weeklyTrendSection

                // 锻炼类型筛选
                filterSection

                // 锻炼记录列表
                workoutListSection

                // 活动统计
                activityStatsSection
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
        }
        .background(Color.hpGroupedBackground)
        .navigationTitle("健身")
        .navigationBarTitleDisplayMode(.large)
        .sheet(item: $showWorkoutDetail) { workout in
            WorkoutDetailView(workout: workout)
        }
    }

    // MARK: - 今日活动
    private var todayActivitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("今日活动")
                .font(.hpHeadline)
                .fontWeight(.semibold)

            HStack(spacing: 12) {
                activityMetricCard(
                    icon: "figure.run",
                    color: .hpGreen,
                    title: "步数",
                    value: appState.steps.withComma,
                    unit: "步",
                    progress: Double(appState.steps) / Double(appState.dailyStepGoal)
                )
                activityMetricCard(
                    icon: "flame.fill",
                    color: .hpOrange,
                    title: "卡路里",
                    value: "\(Int(appState.activeCalories))",
                    unit: "千卡",
                    progress: appState.activeCalories / appState.dailyCalorieGoal
                )
            }

            HStack(spacing: 12) {
                activityMetricCard(
                    icon: "clock.fill",
                    color: .hpTeal,
                    title: "锻炼",
                    value: "\(Int(appState.exerciseMinutes))",
                    unit: "分钟",
                    progress: appState.exerciseMinutes / 30
                )
                activityMetricCard(
                    icon: "figure.stand",
                    color: .hpBlue,
                    title: "站立",
                    value: "\(Int(appState.standHours))",
                    unit: "小时",
                    progress: appState.standHours / 12
                )
            }
        }
        .padding(16)
        .background(Color.hpSecondaryGroupedBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func activityMetricCard(icon: String, color: Color, title: String, value: String, unit: String, progress: Double) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(color)
                Text(title)
                    .font(.hpCaption2)
                    .foregroundStyle(.hpSecondaryLabel)
            }
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(value)
                    .font(.hpMetric(22))
                    .foregroundStyle(.hpLabel)
                Text(unit)
                    .font(.hpCaption2)
                    .foregroundStyle(.hpTertiaryLabel)
            }
            HorizontalProgressBar(progress: progress, color: color, height: 5)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.hpTertiaryFill.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    // MARK: - 周趋势
    private var weeklyTrendSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("本周活动趋势")
                .font(.hpHeadline)
                .fontWeight(.semibold)

            if !appState.weeklySteps.isEmpty {
                Chart {
                    ForEach(appState.weeklySteps) { point in
                        BarMark(
                            x: .value("日期", point.date, unit: .day),
                            y: .value("步数", point.value)
                        )
                        .foregroundStyle(
                            point.value >= Double(appState.dailyStepGoal) ? Color.hpGreen : Color.hpBlue
                        )
                        .cornerRadius(4)
                    }
                    RuleMark(y: .value("目标", Double(appState.dailyStepGoal)))
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
                        AxisValueLabel(format: .number.notation(.compactName))
                            .font(.hpCaption2)
                    }
                }
                .frame(height: 160)
            }
        }
        .padding(16)
        .background(Color.hpSecondaryGroupedBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    // MARK: - 筛选
    private var filterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterChip(title: "全部", icon: "line.3.horizontal.decrease", isSelected: selectedFilter == nil) {
                    selectedFilter = nil
                }
                ForEach(WorkoutType.allCases) { type in
                    FilterChip(title: type.displayName, icon: type.systemImage, isSelected: selectedFilter == type) {
                        selectedFilter = type
                    }
                }
            }
        }
    }

    // MARK: - 锻炼列表
    private var workoutListSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("锻炼记录")
                .font(.hpHeadline)
                .fontWeight(.semibold)

            if filteredWorkouts.isEmpty {
                Text("暂无锻炼记录")
                    .font(.hpFootnote)
                    .foregroundStyle(.hpSecondaryLabel)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 24)
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(filteredWorkouts.enumerated()), id: \.element.id) { index, workout in
                        Button {
                            showWorkoutDetail = workout
                        } label: {
                            WorkoutRow(workout: workout)
                        }
                        .buttonStyle(.plain)
                        if index < filteredWorkouts.count - 1 {
                            Divider().padding(.leading, 52)
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(Color.hpSecondaryGroupedBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    // MARK: - 活动统计
    private var activityStatsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("本周统计")
                .font(.hpHeadline)
                .fontWeight(.semibold)

            let totalWorkouts = appState.recentWorkouts.count
            let totalDuration = appState.recentWorkouts.reduce(0) { $0 + $1.durationMinutes }
            let totalCalories = appState.recentWorkouts.reduce(0.0) { $0 + $1.calories }
            let totalDistance = appState.recentWorkouts.reduce(0.0) { $0 + ($1.distance ?? 0) }

            HStack(spacing: 12) {
                statBox(title: "锻炼次数", value: "\(totalWorkouts)", unit: "次", color: .hpGreen)
                statBox(title: "总时长", value: "\(Int(totalDuration))", unit: "分钟", color: .hpBlue)
            }
            HStack(spacing: 12) {
                statBox(title: "总消耗", value: "\(Int(totalCalories))", unit: "千卡", color: .hpOrange)
                statBox(title: "总距离", value: String(format: "%.1f", totalDistance / 1000), unit: "公里", color: .hpTeal)
            }
        }
        .padding(16)
        .background(Color.hpSecondaryGroupedBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func statBox(title: String, value: String, unit: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.hpCaption)
                .foregroundStyle(.hpSecondaryLabel)
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(value)
                    .font(.hpMetric(24))
                    .foregroundStyle(color)
                Text(unit)
                    .font(.hpCaption2)
                    .foregroundStyle(.hpTertiaryLabel)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.hpTertiaryFill.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

/// 锻炼详情页
struct WorkoutDetailView: View {
    let workout: WorkoutRecord
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 头部
                    VStack(spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .fill(workout.type == .running || workout.type == .walking ? Color.hpGreen.opacity(0.15) : Color.hpBlue.opacity(0.15))
                                .frame(width: 80, height: 80)
                            Image(systemName: workout.type.systemImage)
                                .font(.system(size: 36))
                                .foregroundStyle(workout.type == .running || workout.type == .walking ? .hpGreen : .hpBlue)
                        }

                        Text(workout.type.displayName)
                            .font(.hpTitle2)
                            .fontWeight(.bold)

                        Text(workout.startDate.fullDateTimeString)
                            .font(.hpFootnote)
                            .foregroundStyle(.hpSecondaryLabel)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)

                    // 数据网格
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        detailBox(title: "时长", value: workout.durationString, icon: "clock.fill")
                        detailBox(title: "消耗", value: "\(Int(workout.calories)) 千卡", icon: "flame.fill")
                        if let distance = workout.distance, distance > 0 {
                            detailBox(title: "距离", value: String(format: "%.2f 公里", distance / 1000), icon: "location.fill")
                        }
                        if let hr = workout.averageHeartRate {
                            detailBox(title: "平均心率", value: "\(Int(hr)) BPM", icon: "heart.fill")
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
            .background(Color.hpGroupedBackground)
            .navigationTitle("锻炼详情")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") { dismiss() }
                        .fontWeight(.semibold)
                }
            }
        }
    }

    private func detailBox(title: String, value: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                    .foregroundStyle(.hpAccent)
                Text(title)
                    .font(.hpCaption)
                    .foregroundStyle(.hpSecondaryLabel)
            }
            Text(value)
                .font(.hpTitle3)
                .fontWeight(.semibold)
                .foregroundStyle(.hpLabel)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.hpSecondaryGroupedBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

#Preview {
    NavigationStack {
        FitnessView()
            .environmentObject(AppState())
    }
}
