import SwiftUI

/// 新建心情记录
struct MoodEntryView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var selectedMood: MoodLevel = .neutral
    @State private var selectedEmotion: EmotionType = .calm
    @State private var selectedAssociations: [LifeAssociation] = []
    @State private var note = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("整体心情") {
                    HStack(spacing: 8) {
                        ForEach(MoodLevel.allCases) { mood in
                            Button {
                                selectedMood = mood
                            } label: {
                                VStack(spacing: 4) {
                                    Text(mood.emoji)
                                        .font(.system(size: 28))
                                        .scaleEffect(selectedMood == mood ? 1.2 : 1.0)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(selectedMood == mood ? mood.color.opacity(0.2) : Color.clear)
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            }
                            .buttonStyle(.plain)
                            .animation(.spring(response: 0.3), value: selectedMood)
                        }
                    }
                }

                Section("具体情绪") {
                    let emotions = EmotionType.allCases
                    let columns = [GridItem(.adaptive(minimum: 70), spacing: 8)]
                    LazyVGrid(columns: columns, spacing: 8) {
                        ForEach(emotions) { emotion in
                            Button {
                                selectedEmotion = emotion
                            } label: {
                                VStack(spacing: 4) {
                                    Text(emotion.emoji)
                                        .font(.system(size: 24))
                                    Text(emotion.rawValue)
                                        .font(.hpCaption2)
                                        .foregroundStyle(.hpSecondaryLabel)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.7)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(selectedEmotion == emotion ? Color.hpPurple.opacity(0.15) : Color.clear)
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                Section("关联因素") {
                    let columns = [GridItem(.adaptive(minimum: 90), spacing: 8)]
                    LazyVGrid(columns: columns, spacing: 8) {
                        ForEach(LifeAssociation.allCases) { assoc in
                            FilterChip(
                                title: assoc.rawValue,
                                icon: assoc.systemImage,
                                isSelected: selectedAssociations.contains(assoc)
                            ) {
                                if let index = selectedAssociations.firstIndex(of: assoc) {
                                    selectedAssociations.remove(at: index)
                                } else {
                                    selectedAssociations.append(assoc)
                                }
                            }
                        }
                    }
                }

                Section("备注") {
                    TextEditor(text: $note)
                        .frame(minHeight: 80)
                        .font(.hpBody)
                }
            }
            .navigationTitle("记录心情")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        saveMood()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }

    private func saveMood() {
        let entry = MoodEntry(
            mood: selectedMood,
            valence: selectedEmotion.valence,
            emotion: selectedEmotion,
            associations: selectedAssociations,
            note: note
        )
        appState.addMoodEntry(entry)
    }
}

/// 心理量表评估视图
struct ScaleAssessmentView: View {
    let scale: MentalHealthScale
    @Environment(\.dismiss) private var dismiss
    @State private var answers: [Int]
    @State private var showResult = false

    init(scale: MentalHealthScale) {
        self.scale = scale
        _answers = State(initialValue: Array(repeating: 0, count: scale.questions.count))
    }

    private var totalScore: Int {
        answers.reduce(0, +)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if showResult {
                        resultView
                    } else {
                        questionsView
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
            .background(Color.hpGroupedBackground)
            .navigationTitle(scale.rawValue)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("关闭") { dismiss() }
                }
                if !showResult {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("提交") {
                            withAnimation { showResult = true }
                        }
                        .fontWeight(.semibold)
                    }
                }
            }
        }
    }

    private var questionsView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("请根据过去两周的情况，对每道题进行评分")
                .font(.hpFootnote)
                .foregroundStyle(.hpSecondaryLabel)

            ForEach(Array(scale.questions.enumerated()), id: \.offset) { index, question in
                VStack(alignment: .leading, spacing: 10) {
                    HStack(alignment: .top, spacing: 8) {
                        Text("\(index + 1)")
                            .font(.hpSubheadline)
                            .fontWeight(.bold)
                            .foregroundStyle(.hpAccent)
                            .frame(width: 24)
                        Text(question)
                            .font(.hpBody)
                            .foregroundStyle(.hpLabel)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    // 0-3 评分
                    HStack(spacing: 6) {
                        ForEach(0...3, id: \.self) { score in
                            Button {
                                answers[index] = score
                            } label: {
                                VStack(spacing: 2) {
                                    Text("\(score)")
                                        .font(.hpSubheadline)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(answers[index] == score ? .white : .hpLabel)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(answers[index] == score ? Color.hpAccent : Color.hpTertiaryFill)
                                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    HStack {
                        Text("完全不会")
                            .font(.hpCaption2)
                            .foregroundStyle(.hpTertiaryLabel)
                        Spacer()
                        Text("几乎每天")
                            .font(.hpCaption2)
                            .foregroundStyle(.hpTertiaryLabel)
                    }
                }
                .padding(14)
                .background(Color.hpSecondaryGroupedBackground)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
        }
    }

    private var resultView: some View {
        let result = scale.interpretation(score: totalScore)
        return VStack(spacing: 20) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(result.color.opacity(0.15))
                        .frame(width: 100, height: 100)
                    VStack(spacing: 2) {
                        Text("\(totalScore)")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundStyle(result.color)
                        Text("分")
                            .font(.hpCaption)
                            .foregroundStyle(.hpSecondaryLabel)
                    }
                }

                Text(result.level)
                    .font(.hpTitle2)
                    .fontWeight(.bold)
                    .foregroundStyle(result.color)

                Text(result.advice)
                    .font(.hpBody)
                    .foregroundStyle(.hpSecondaryLabel)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(20)
            .background(Color.hpSecondaryGroupedBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: "info.circle.fill")
                        .foregroundStyle(.hpBlue)
                    Text("评估说明")
                        .font(.hpSubheadline)
                        .fontWeight(.semibold)
                }
                Text("本评估仅供参考，不能替代专业诊断。如果你感到持续的心理困扰，建议寻求专业心理咨询师或医生的帮助。")
                    .font(.hpFootnote)
                    .foregroundStyle(.hpSecondaryLabel)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(16)
            .background(Color.hpSecondaryGroupedBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

            Button {
                withAnimation {
                    showResult = false
                    answers = Array(repeating: 0, count: scale.questions.count)
                }
            } label: {
                Text("重新评估")
                    .font(.hpSubheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.hpAccent)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .buttonStyle(.plain)
        }
    }
}
