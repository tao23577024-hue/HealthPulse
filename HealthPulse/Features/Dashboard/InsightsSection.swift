import SwiftUI

/// 洞察区域 — 展示健康洞察和提醒
struct InsightsSection: View {
    let insights: [HealthInsight]
    var onTapInsight: ((HealthInsight) -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if insights.isEmpty {
                emptyState
            } else {
                ForEach(insights.prefix(5)) { insight in
                    InsightCard(insight: insight) {
                        onTapInsight?(insight)
                    }
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 32))
                .foregroundStyle(.hpGreen)
            Text("一切正常")
                .font(.hpHeadline)
                .foregroundStyle(.hpLabel)
            Text("没有需要关注的健康洞察")
                .font(.hpFootnote)
                .foregroundStyle(.hpSecondaryLabel)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .padding(.horizontal, 16)
        .background(Color.hpSecondaryGroupedBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

/// 单条洞察卡片
struct InsightCard: View {
    let insight: HealthInsight
    var onTap: (() -> Void)?

    var body: some View {
        Button(action: { onTap?() }) {
            HStack(alignment: .top, spacing: 12) {
                // 图标
                ZStack {
                    Circle()
                        .fill(insight.severity.color.opacity(0.15))
                        .frame(width: 36, height: 36)
                    Image(systemName: insight.severity.icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(insight.severity.color)
                }

                // 内容
                VStack(alignment: .leading, spacing: 4) {
                    Text(insight.title)
                        .font(.hpSubheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.hpLabel)
                        .multilineTextAlignment(.leading)

                    Text(insight.message)
                        .font(.hpFootnote)
                        .foregroundStyle(.hpSecondaryLabel)
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)

                    // 证据
                    HStack(spacing: 4) {
                        Image(systemName: "info.circle")
                            .font(.system(size: 10))
                        Text(insight.evidence)
                            .font(.hpCaption2)
                    }
                    .foregroundStyle(.hpTertiaryLabel)
                }

                Spacer(minLength: 0)

                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.hpTertiaryLabel)
                    .padding(.top, 4)
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.hpSecondaryGroupedBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(insight.severity.color.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ScrollView {
        InsightsSection(insights: [
            HealthInsight(
                type: .sleep,
                title: "睡眠不足",
                message: "昨晚睡眠 6.5 小时，略低于推荐范围。短期睡眠减少可能影响注意力和情绪。",
                severity: .warning,
                evidence: "昨晚睡眠: 6.5 小时"
            ),
            HealthInsight(
                type: .activity,
                title: "达成步数目标",
                message: "今天已走 10,500 步，达成每日目标！保持活跃对心血管健康有积极影响。",
                severity: .positive,
                evidence: "今日步数: 10,500 / 目标: 10,000"
            ),
            HealthInsight(
                type: .heartRate,
                title: "静息心率良好",
                message: "你的静息心率为 62 bpm，处于健康范围内。",
                severity: .positive,
                evidence: "本周静息心率: 62 bpm"
            )
        ])
        .padding()
    }
    .background(Color.hpGroupedBackground)
}
