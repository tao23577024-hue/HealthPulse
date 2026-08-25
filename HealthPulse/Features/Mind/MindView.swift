import SwiftUI
import Charts

/// 心情记录页面 — 记录心情、情绪、心理量表
struct MindView: View {
    @EnvironmentObject var appState: AppState
    @State private var showMoodEntry = false
    @State private var selectedScale: MentalHealthScale?

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 今日心情
                todayMoodSection

                // 心情趋势
                if !appState.moodEntries.isEmpty {
                    moodTrendSection
                }

                // 心理量表
                scalesSection

                // 最近心情记录
                recentMoodsSection

                // 心理健康资源
                resourcesSection
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
        }
        .background(Color.hpGroupedBackground)
        .navigationTitle("心情")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showMoodEntry = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 20))
                }
            }
        }
        .sheet(isPresented: $showMoodEntry) {
            MoodEntryView()
                .environmentObject(appState)
        }
        .sheet(item: $selectedScale) { scale in
            ScaleAssessmentView(scale: scale)
        }
    }

    // MARK: - 今日心情
    private var todayMoodSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("今日心情")
                .font(.hpHeadline)
                .fontWeight(.semibold)

            if let todayMood = appState.moodEntries.first(where: { Calendar.current.isDateInToday($0.date) }) {
                HStack(spacing: 16) {
                    Text(todayMood.emotion.emoji)
                        .font(.system(size: 48))
                    VStack(alignment: .leading, spacing: 4) {
                        Text(todayMood.emotion.rawValue)
                            .font(.hpTitle3)
                            .fontWeight(.semibold)
                            .foregroundStyle(.hpLabel)
                        Text(todayMood.mood.displayName)
                            .font(.hpFootnote)
                            .foregroundStyle(.hpSecondaryLabel)
                        if !todayMood.note.isEmpty {
                            Text(todayMood.note)
                                .font(.hpCaption)
                                .foregroundStyle(.hpTertiaryLabel)
                                .lineLimit(2)
                        }
                    }
                    Spacer()
                }
                .padding(16)
                .background(todayMood.mood.color.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            } else {
                Button {
                    showMoodEntry = true
                } label: {
                    HStack {
                        Image(systemName: "face.smiling")
                            .font(.system(size: 24))
                            .foregroundStyle(.hpPurple)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("记录今天的心情")
                                .font(.hpSubheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(.hpLabel)
                            Text("花几秒钟记录你的情绪状态")
                                .font(.hpCaption2)
                                .foregroundStyle(.hpSecondaryLabel)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12))
                            .foregroundStyle(.hpTertiaryLabel)
                    }
                    .padding(16)
                    .background(Color.hpSecondaryGroupedBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - 心情趋势
    private var moodTrendSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("心情趋势")
                .font(.hpHeadline)
                .fontWeight(.semibold)

            let recentMoods = Array(appState.moodEntries.prefix(7).reversed())
            Chart(recentMoods) { mood in
                LineMark(
                    x: .value("日期", mood.date, unit: .day),
                    y: .value("心情", mood.mood.rawValue)
                )
                .foregroundStyle(Color.hpPurple)
                .lineStyle(StrokeStyle(lineWidth: 2.5, lineCap: .round))

                PointMark(
                    x: .value("日期", mood.date, unit: .day),
                    y: .value("心情", mood.mood.rawValue)
                )
                .foregroundStyle(mood.mood.color)
                .symbolSize(50)
            }
            .chartXAxis {
                AxisMarks(position: .bottom, values: .stride(by: .day)) { value in
                    AxisValueLabel(format: .dateTime.weekday(.narrow))
                        .font(.hpCaption2)
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading, values: [1, 3, 5]) { value in
                    AxisGridLine().foregroundStyle(Color.hpSeparator.opacity(0.2))
                    AxisValueLabel {
                        if let v = value.as(Int.self) {
                            Text(MoodLevel(rawValue: v)?.displayName ?? "")
                                .font(.hpCaption2)
                        }
                    }
                }
            }
            .chartYScale(domain: 1...5)
            .frame(height: 160)
        }
        .padding(16)
        .background(Color.hpSecondaryGroupedBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    // MARK: - 心理量表
    private var scalesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("心理评估")
                .font(.hpHeadline)
                .fontWeight(.semibold)

            ForEach(MentalHealthScale.allCases) { scale in
                Button {
                    selectedScale = scale
                } label: {
                    HStack(spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(Color.hpPurple.opacity(0.12))
                                .frame(width: 40, height: 40)
                            Image(systemName: "clipboard.fill")
                                .font(.system(size: 18))
                                .foregroundStyle(.hpPurple)
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text(scale.rawValue)
                                .font(.hpSubheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(.hpLabel)
                            Text("\(scale.questions.count) 道题 · 约 2 分钟")
                                .font(.hpCaption2)
                                .foregroundStyle(.hpTertiaryLabel)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12))
                            .foregroundStyle(.hpTertiaryLabel)
                    }
                    .padding(.vertical, 4)
                }
                .buttonStyle(.plain)

                if scale != MentalHealthScale.allCases.last {
                    Divider().padding(.leading, 52)
                }
            }
        }
        .padding(16)
        .background(Color.hpSecondaryGroupedBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    // MARK: - 最近心情
    private var recentMoodsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("最近记录")
                .font(.hpHeadline)
                .fontWeight(.semibold)

            if appState.moodEntries.isEmpty {
                Text("暂无心情记录")
                    .font(.hpFootnote)
                    .foregroundStyle(.hpSecondaryLabel)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 16)
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(appState.moodEntries.prefix(5).enumerated()), id: \.element.id) { index, mood in
                        HStack(spacing: 12) {
                            Text(mood.emotion.emoji)
                                .font(.system(size: 24))
                            VStack(alignment: .leading, spacing: 2) {
                                Text(mood.emotion.rawValue)
                                    .font(.hpSubheadline)
                                    .fontWeight(.medium)
                                    .foregroundStyle(.hpLabel)
                                Text(mood.date.relativeTimeString)
                                    .font(.hpCaption2)
                                    .foregroundStyle(.hpTertiaryLabel)
                            }
                            Spacer()
                            if !mood.associations.isEmpty {
                                HStack(spacing: 4) {
                                    ForEach(mood.associations.prefix(2), id: \.self) { assoc in
                                        Image(systemName: assoc.systemImage)
                                            .font(.system(size: 12))
                                            .foregroundStyle(.hpTertiaryLabel)
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 8)

                        if index < min(appState.moodEntries.count, 5) - 1 {
                            Divider().padding(.leading, 36)
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(Color.hpSecondaryGroupedBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    // MARK: - 资源
    private var resourcesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: "heart.text.square.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(.hpRed)
                Text("心理健康资源")
                    .font(.hpHeadline)
                    .fontWeight(.semibold)
            }

            VStack(alignment: .leading, spacing: 10) {
                resourceRow(icon: "phone.fill", title: "心理援助热线", detail: "全国心理援助热线：400-161-9995")
                resourceRow(icon: "bubble.left.and.bubble.right.fill", title: "心理咨询", detail: "建议寻求专业心理咨询师的帮助")
                resourceRow(icon: "leaf.fill", title: "正念冥想", detail: "每天10分钟正念练习有助于缓解焦虑")
                resourceRow(icon: "figure.run", title: "运动减压", detail: "规律运动是天然的抗抑郁剂")
            }
        }
        .padding(16)
        .background(Color.hpSecondaryGroupedBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func resourceRow(icon: String, title: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(.hpPurple)
                .frame(width: 20)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.hpFootnote)
                    .fontWeight(.medium)
                    .foregroundStyle(.hpLabel)
                Text(detail)
                    .font(.hpCaption2)
                    .foregroundStyle(.hpSecondaryLabel)
            }
        }
    }
}

#Preview {
    NavigationStack {
        MindView()
            .environmentObject(AppState())
    }
}
