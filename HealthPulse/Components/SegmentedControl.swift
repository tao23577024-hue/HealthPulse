import SwiftUI

/// 苹果风格分段控件
struct SegmentedControl: View {
    @Binding var selectedIndex: Int
    let items: [String]
    var height: CGFloat = 36

    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<items.count, id: \.self) { index in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedIndex = index
                    }
                } label: {
                    Text(items[index])
                        .font(.hpSubheadline)
                        .fontWeight(selectedIndex == index ? .semibold : .regular)
                        .foregroundStyle(selectedIndex == index ? .hpLabel : .hpSecondaryLabel)
                        .frame(maxWidth: .infinity)
                        .frame(height: height - 6)
                        .background(
                            RoundedRectangle(cornerRadius: 7, style: .continuous)
                                .fill(Color.hpSecondaryGroupedBackground)
                                .opacity(selectedIndex == index ? 1 : 0)
                        )
                        .shadow(color: .black.opacity(0.05), radius: 1, x: 0, y: 1)
                        .opacity(selectedIndex == index ? 1 : 0.8)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(3)
        .frame(height: height)
        .background(Color.hpTertiaryFill)
        .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
    }
}

/// 时间范围选择器（日/周/月/年）
struct TimeRangeSelector: View {
    @Binding var selectedRange: TimeRange
    var onRangeChange: ((TimeRange) -> Void)?

    enum TimeRange: String, CaseIterable, Identifiable {
        case day = "日"
        case week = "周"
        case month = "月"
        case year = "年"

        var id: String { rawValue }
    }

    var body: some View {
        SegmentedControl(
            selectedIndex: Binding(
                get: { TimeRange.allCases.firstIndex(of: selectedRange) ?? 0 },
                set: { newIndex in
                    selectedRange = TimeRange.allCases[newIndex]
                    onRangeChange?(selectedRange)
                }
            ),
            items: TimeRange.allCases.map { $0.rawValue }
        )
    }
}

/// 筛选标签（可多选）
struct FilterChip: View {
    let title: String
    let icon: String?
    var isSelected: Bool
    var onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 4) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 12, weight: .medium))
                }
                Text(title)
                    .font(.hpFootnote)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .foregroundStyle(isSelected ? .white : .hpLabel)
            .background(isSelected ? Color.hpAccent : Color.hpSecondaryFill)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack(spacing: 20) {
        SegmentedControl(selectedIndex: .constant(1), items: ["日", "周", "月", "年"])

        TimeRangeSelector(selectedRange: .constant(.week))

        HStack {
            FilterChip(title: "全部", icon: "line.3.horizontal.decrease", isSelected: true) {}
            FilterChip(title: "跑步", icon: "figure.run", isSelected: false) {}
            FilterChip(title: "力量", icon: "dumbbell.fill", isSelected: false) {}
        }
    }
    .padding()
    .background(Color.hpGroupedBackground)
}
