import Foundation

/// 健康洞察引擎 — 纯函数规则引擎，根据健康数据生成可解释的洞察
/// 设计参考 Health Companion 的 InsightsEngine，每条洞察都附带证据
final class InsightsEngine {

    func generateInsights(
        heartRate: Double,
        restingHeartRate: Double,
        hrv: Double,
        steps: Int,
        stepGoal: Int,
        sleepHours: Double,
        sleepGoal: Double,
        deepSleepMinutes: Double,
        sleepEfficiency: Double,
        activeCalories: Double,
        exerciseMinutes: Double,
        weeklySteps: [DailyMetric],
        weeklyHeartRate: [DailyMetric],
        weeklySleep: [DailyMetric],
        weeklyHRV: [DailyMetric]
    ) -> [HealthInsight] {
        var insights: [HealthInsight] = []

        // MARK: - 心率洞察
        if restingHeartRate > 0 {
            if restingHeartRate > 80 {
                insights.append(HealthInsight(
                    type: .heartRate,
                    title: "静息心率偏高",
                    message: "你的静息心率为 \(Int(restingHeartRate)) bpm，高于一般健康范围（60-80 bpm）。短期升高可能与压力、疾病、睡眠不足或酒精有关。",
                    severity: .warning,
                    evidence: "本周静息心率: \(Int(restingHeartRate)) bpm"
                ))
            } else if restingHeartRate < 50 {
                insights.append(HealthInsight(
                    type: .heartRate,
                    title: "静息心率较低",
                    message: "你的静息心率为 \(Int(restingHeartRate)) bpm。对于经常运动的人来说这是正常的，但如果伴有头晕或乏力，建议咨询医生。",
                    severity: .neutral,
                    evidence: "本周静息心率: \(Int(restingHeartRate)) bpm"
                ))
            } else {
                insights.append(HealthInsight(
                    type: .heartRate,
                    title: "静息心率良好",
                    message: "你的静息心率为 \(Int(restingHeartRate)) bpm，处于健康范围内。继续保持良好的生活方式。",
                    severity: .positive,
                    evidence: "本周静息心率: \(Int(restingHeartRate)) bpm"
                ))
            }
        }

        // 心率趋势
        if weeklyHeartRate.count >= 2 {
            let recent = weeklyHeartRate.suffix(3).map { $0.value }.filter { $0 > 0 }
            let earlier = weeklyHeartRate.prefix(weeklyHeartRate.count - 3).map { $0.value }.filter { $0 > 0 }
            if recent.count >= 2, earlier.count >= 2 {
                let recentAvg = recent.reduce(0, +) / Double(recent.count)
                let earlierAvg = earlier.reduce(0, +) / Double(earlier.count)
                if recentAvg > earlierAvg * 1.1 {
                    insights.append(HealthInsight(
                        type: .heartRate,
                        title: "心率呈上升趋势",
                        message: "近三天平均心率比之前高出约 \(Int((recentAvg / earlierAvg - 1) * 100))%。关注是否有压力增大、睡眠减少或身体不适。",
                        severity: .warning,
                        evidence: "近3天均值: \(Int(recentAvg)) bpm vs 之前: \(Int(earlierAvg)) bpm"
                    ))
                }
            }
        }

        // MARK: - HRV 洞察
        if hrv > 0 {
            if hrv < 20 {
                insights.append(HealthInsight(
                    type: .recovery,
                    title: "HRV 偏低",
                    message: "你的心率变异性为 \(Int(hrv)) ms，低于一般范围。HRV 偏低通常反映较高的压力、疲劳或恢复不足。建议增加休息和放松。",
                    severity: .warning,
                    evidence: "当前 HRV: \(Int(hrv)) ms"
                ))
            } else if hrv > 100 {
                insights.append(HealthInsight(
                    type: .recovery,
                    title: "HRV 良好",
                    message: "你的心率变异性为 \(Int(hrv)) ms，处于较高水平，说明自主神经系统平衡良好，恢复状态佳。",
                    severity: .positive,
                    evidence: "当前 HRV: \(Int(hrv)) ms"
                ))
            }
        }

        // MARK: - 活动/步数洞察
        if steps > 0 {
            let progress = Double(steps) / Double(stepGoal)
            if progress >= 1.0 {
                insights.append(HealthInsight(
                    type: .activity,
                    title: "达成步数目标",
                    message: "今天已走 \(steps) 步，达成每日 \(stepGoal) 步的目标！保持活跃对心血管健康和睡眠质量都有积极影响。",
                    severity: .positive,
                    evidence: "今日步数: \(steps) / 目标: \(stepGoal)"
                ))
            } else if progress < 0.3 {
                insights.append(HealthInsight(
                    type: .activity,
                    title: "活动量不足",
                    message: "今天仅走了 \(steps) 步，不到目标的 \(Int(progress * 100))%。久坐与多种健康风险相关，建议每小时起身活动几分钟。",
                    severity: .warning,
                    evidence: "今日步数: \(steps) / 目标: \(stepGoal)"
                ))
            }
        }

        // 步数周趋势
        if weeklySteps.count >= 7 {
            let thisWeek = weeklySteps.suffix(3).map { $0.value }.reduce(0, +) / 3
            let lastWeek = weeklySteps.prefix(4).map { $0.value }.reduce(0, +) / 4
            if thisWeek > lastWeek * 1.2 {
                insights.append(HealthInsight(
                    type: .activity,
                    title: "活动量增加",
                    message: "近三天日均步数比之前增加了约 \(Int((thisWeek / lastWeek - 1) * 100))%。活动量的提升有助于改善心肺功能和睡眠。",
                    severity: .positive,
                    evidence: "近3天日均: \(Int(thisWeek)) 步 vs 之前: \(Int(lastWeek)) 步"
                ))
            }
        }

        // MARK: - 睡眠洞察
        if sleepHours > 0 {
            if sleepHours < 6 {
                insights.append(HealthInsight(
                    type: .sleep,
                    title: "睡眠严重不足",
                    message: "昨晚只睡了 \(String(format: "%.1f", sleepHours)) 小时，远低于推荐的 7-9 小时。长期睡眠不足会影响认知功能、免疫力和代谢健康。",
                    severity: .critical,
                    evidence: "昨晚睡眠: \(String(format: "%.1f", sleepHours)) 小时"
                ))
            } else if sleepHours < 7 {
                insights.append(HealthInsight(
                    type: .sleep,
                    title: "睡眠不足",
                    message: "昨晚睡眠 \(String(format: "%.1f", sleepHours)) 小时，略低于推荐范围。短期睡眠减少可能影响注意力和情绪。",
                    severity: .warning,
                    evidence: "昨晚睡眠: \(String(format: "%.1f", sleepHours)) 小时"
                ))
            } else if sleepHours >= 7 && sleepHours <= 9 {
                insights.append(HealthInsight(
                    type: .sleep,
                    title: "睡眠时长良好",
                    message: "昨晚睡眠 \(String(format: "%.1f", sleepHours)) 小时，在推荐的 7-9 小时范围内。充足的睡眠是恢复和健康的基础。",
                    severity: .positive,
                    evidence: "昨晚睡眠: \(String(format: "%.1f", sleepHours)) 小时"
                ))
            }
        }

        // 深睡比例
        if sleepHours > 0 && deepSleepMinutes > 0 {
            let deepPercent = deepSleepMinutes / (sleepHours * 60)
            if deepPercent < 0.1 {
                insights.append(HealthInsight(
                    type: .sleep,
                    title: "深睡比例偏低",
                    message: "深睡占总睡眠的 \(Int(deepPercent * 100))%，低于推荐的 13-23%。深睡对身体恢复和记忆巩固很重要。睡前避免酒精和屏幕可能有帮助。",
                    severity: .warning,
                    evidence: "深睡: \(Int(deepSleepMinutes)) 分钟 / 总睡眠: \(Int(sleepHours * 60)) 分钟"
                ))
            }
        }

        // 睡眠效率
        if sleepEfficiency > 0 {
            if sleepEfficiency < 0.75 {
                insights.append(HealthInsight(
                    type: .sleep,
                    title: "睡眠效率偏低",
                    message: "睡眠效率为 \(Int(sleepEfficiency * 100))%，低于 85% 的良好标准。可能存在入睡困难或夜间频繁醒来的情况。",
                    severity: .warning,
                    evidence: "睡眠效率: \(Int(sleepEfficiency * 100))%"
                ))
            }
        }

        // 睡眠周趋势
        if weeklySleep.count >= 4 {
            let recentSleep = weeklySleep.suffix(3).map { $0.value }.filter { $0 > 0 }
            if recentSleep.count >= 2 {
                let avg = recentSleep.reduce(0, +) / Double(recentSleep.count)
                if avg < 6.5 {
                    insights.append(HealthInsight(
                        type: .sleep,
                        title: "近期睡眠持续偏少",
                        message: "近几天平均睡眠仅 \(String(format: "%.1f", avg)) 小时。持续睡眠不足会累积疲劳，影响免疫力和认知功能。建议优先调整作息。",
                        severity: .warning,
                        evidence: "近\(recentSleep.count)天平均睡眠: \(String(format: "%.1f", avg)) 小时"
                    ))
                }
            }
        }

        // MARK: - 锻炼洞察
        if exerciseMinutes >= 30 {
            insights.append(HealthInsight(
                type: .activity,
                title: "锻炼达标",
                message: "今天已锻炼 \(Int(exerciseMinutes)) 分钟，达到 WHO 推荐的每日 30 分钟中等强度活动标准。",
                severity: .positive,
                evidence: "今日锻炼: \(Int(exerciseMinutes)) 分钟"
            ))
        }

        // MARK: - 综合洞察
        if sleepHours > 0 && steps > 0 {
            if sleepHours < 6.5 && Double(steps) < Double(stepGoal) * 0.5 {
                insights.append(HealthInsight(
                    type: .general,
                    title: "睡眠和活动都偏低",
                    message: "昨晚睡眠不足且今天活动量也较低。这两者常常相互影响——睡眠不好会减少活动动力，而活动不足又会影响当晚睡眠质量。建议今天适当散步，今晚提前入睡。",
                    severity: .warning,
                    evidence: "睡眠: \(String(format: "%.1f", sleepHours))h, 步数: \(steps)"
                ))
            }
        }

        // 按严重程度排序：critical > warning > neutral > positive
        insights.sort { lhs, rhs in
            severityRank(lhs.severity) > severityRank(rhs.severity)
        }

        return insights
    }

    private func severityRank(_ severity: InsightSeverity) -> Int {
        switch severity {
        case .critical: return 4
        case .warning: return 3
        case .neutral: return 2
        case .positive: return 1
        }
    }
}
