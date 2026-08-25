import SwiftUI

/// 健康日志页面 — 记录日常健康感受、症状、用药等
struct JournalView: View {
    @EnvironmentObject var appState: AppState
    @State private var showNewEntry = false

    var body: some View {
        List {
            if appState.journalEntries.isEmpty {
                emptyState
            } else {
                ForEach(appState.journalEntries) { entry in
                    journalRow(entry: entry)
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                appState.removeJournalEntry(entry)
                            } label: {
                                Label("删除", systemImage: "trash.fill")
                            }
                        }
                }
            }
        }
        .listStyle(.plain)
        .background(Color.hpGroupedBackground)
        .navigationTitle("健康日志")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showNewEntry = true
                } label: {
                    Image(systemName: "square.and.pencil")
                        .font(.system(size: 16, weight: .semibold))
                }
            }
        }
        .sheet(isPresented: $showNewEntry) {
            NewJournalEntryView()
                .environmentObject(appState)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer().frame(height: 60)
            ZStack {
                Circle()
                    .fill(Color.hpAccent.opacity(0.1))
                    .frame(width: 80, height: 80)
                Image(systemName: "book.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(.hpAccent)
            }
            Text("还没有日志记录")
                .font(.hpTitle3)
                .fontWeight(.semibold)
                .foregroundStyle(.hpLabel)
            Text("记录你的日常感受、症状和健康变化")
                .font(.hpFootnote)
                .foregroundStyle(.hpSecondaryLabel)
                .multilineTextAlignment(.center)
            Button {
                showNewEntry = true
            } label: {
                Label("写第一篇日志", systemImage: "plus.circle.fill")
                    .font(.hpSubheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.hpAccent)
                    .clipShape(Capsule())
            }
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .listRowBackground(Color.clear)
    }

    private func journalRow(entry: JournalEntry) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(entry.title)
                    .font(.hpHeadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.hpLabel)
                Spacer()
                Text(entry.relativeDateString)
                    .font(.hpCaption2)
                    .foregroundStyle(.hpTertiaryLabel)
            }

            if !entry.content.isEmpty {
                Text(entry.content)
                    .font(.hpFootnote)
                    .foregroundStyle(.hpSecondaryLabel)
                    .lineLimit(3)
            }

            // 标签和指标
            HStack(spacing: 8) {
                if let mood = entry.mood {
                    HStack(spacing: 3) {
                        Text(mood.emoji)
                            .font(.system(size: 12))
                        Text(mood.displayName)
                            .font(.hpCaption2)
                            .foregroundStyle(.hpSecondaryLabel)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(mood.color.opacity(0.15))
                    .clipShape(Capsule())
                }

                if let pain = entry.painLevel {
                    HStack(spacing: 3) {
                        Image(systemName: "cross.fill")
                            .font(.system(size: 9))
                        Text("疼痛 \(pain)/10")
                            .font(.hpCaption2)
                            .foregroundStyle(.hpSecondaryLabel)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.hpRed.opacity(0.1))
                    .clipShape(Capsule())
                }

                ForEach(entry.tags.prefix(2), id: \.self) { tag in
                    Text("#\(tag)")
                        .font(.hpCaption2)
                        .foregroundStyle(.hpAccent)
                }
            }
        }
        .padding(14)
        .background(Color.hpSecondaryGroupedBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

/// 新建日志条目
struct NewJournalEntryView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var content = ""
    @State private var selectedMood: MoodLevel?
    @State private var painLevel: Int = 0
    @State private var showPainPicker = false
    @State private var newTag = ""
    @State private var tags: [String] = []
    @State private var selectedSymptoms: [String] = []

    var body: some View {
        NavigationStack {
            Form {
                Section("标题") {
                    TextField("今天感觉怎么样？", text: $title)
                        .font(.hpBody)
                }

                Section("内容") {
                    TextEditor(text: $content)
                        .frame(minHeight: 100)
                        .font(.hpBody)
                }

                Section("心情") {
                    HStack(spacing: 12) {
                        ForEach(MoodLevel.allCases) { mood in
                            Button {
                                selectedMood = selectedMood == mood ? nil : mood
                            } label: {
                                VStack(spacing: 4) {
                                    Text(mood.emoji)
                                        .font(.system(size: 24))
                                    Text(mood.displayName)
                                        .font(.hpCaption2)
                                        .foregroundStyle(.hpSecondaryLabel)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(selectedMood == mood ? mood.color.opacity(0.2) : Color.clear)
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                Section("疼痛程度") {
                    Button {
                        showPainPicker.toggle()
                    } label: {
                        HStack {
                            Text("疼痛等级")
                                .foregroundStyle(.hpLabel)
                            Spacer()
                            if painLevel > 0 {
                                Text("\(painLevel) / 10")
                                    .foregroundStyle(.hpRed)
                            } else {
                                Text("无")
                                    .foregroundStyle(.hpSecondaryLabel)
                            }
                            Image(systemName: "chevron.right")
                                .font(.system(size: 11))
                                .foregroundStyle(.hpTertiaryLabel)
                        }
                    }

                    if showPainPicker {
                        VStack(alignment: .leading, spacing: 8) {
                            Slider(value: Binding(
                                get: { Double(painLevel) },
                                set: { painLevel = Int($0) }
                            ), in: 0...10, step: 1)
                            .tint(painLevel > 6 ? .hpRed : painLevel > 3 ? .hpOrange : .hpGreen)

                            HStack {
                                Text("无痛")
                                    .font(.hpCaption2)
                                    .foregroundStyle(.hpGreen)
                                Spacer()
                                Text("中度")
                                    .font(.hpCaption2)
                                    .foregroundStyle(.hpOrange)
                                Spacer()
                                Text("剧烈")
                                    .font(.hpCaption2)
                                    .foregroundStyle(.hpRed)
                            }
                        }
                    }
                }

                Section("症状") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(CommonSymptom.allCases) { symptom in
                                FilterChip(
                                    title: symptom.rawValue,
                                    icon: nil,
                                    isSelected: selectedSymptoms.contains(symptom.rawValue)
                                ) {
                                    if let index = selectedSymptoms.firstIndex(of: symptom.rawValue) {
                                        selectedSymptoms.remove(at: index)
                                    } else {
                                        selectedSymptoms.append(symptom.rawValue)
                                    }
                                }
                            }
                        }
                    }
                }

                Section("标签") {
                    HStack {
                        TextField("添加标签", text: $newTag)
                            .font(.hpBody)
                        Button {
                            if !newTag.isEmpty {
                                tags.append(newTag)
                                newTag = ""
                            }
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .foregroundStyle(.hpAccent)
                        }
                    }

                    if !tags.isEmpty {
                        WrapHStack(items: tags) { tag in
                            HStack(spacing: 4) {
                                Text("#\(tag)")
                                    .font(.hpCaption)
                                    .foregroundStyle(.hpAccent)
                                Button {
                                    tags.removeAll { $0 == tag }
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: 12))
                                        .foregroundStyle(.hpTertiaryLabel)
                                }
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Color.hpAccent.opacity(0.1))
                            .clipShape(Capsule())
                        }
                    }
                }
            }
            .navigationTitle("新日志")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        saveEntry()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(title.isEmpty && content.isEmpty)
                }
            }
        }
    }

    private func saveEntry() {
        let entry = JournalEntry(
            title: title.isEmpty ? "无标题" : title,
            content: content,
            tags: tags,
            painLevel: painLevel > 0 ? painLevel : nil,
            mood: selectedMood,
            symptoms: selectedSymptoms
        )
        appState.addJournalEntry(entry)
    }
}

/// 简单的自动换行HStack
struct WrapHStack<Data: RandomAccessCollection, Content: View>: View where Data.Element: Hashable {
    let items: Data
    let content: (Data.Element) -> Content

    var body: some View {
        // 简化实现：用LazyVGrid
        let columns = [GridItem(.adaptive(minimum: 80), spacing: 8)]
        LazyVGrid(columns: columns, alignment: .leading, spacing: 8) {
            ForEach(items, id: \.self) { item in
                content(item)
            }
        }
    }
}

#Preview {
    NavigationStack {
        JournalView()
            .environmentObject(AppState())
    }
}
