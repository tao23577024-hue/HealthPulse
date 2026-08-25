import Foundation

/// 预览/演示数据 — 用于模拟器和未授权HealthKit时展示
final class PreviewData {
    static let shared = PreviewData()

    // MARK: - 今日指标
    let heartRate: Double = 72
    let restingHeartRate: Double = 62
    let hrv: Double = 45
    let steps: Int = 8432
    let activeCalories: Double = 420
    let exerciseMinutes: Double = 35
    let standHours: Double = 9
    let sleepHours: Double = 7.2
    let deepSleepMinutes: Double = 68
    let remSleepMinutes: Double = 95
    let sleepEfficiency: Double = 0.88
    let bloodOxygen: Double = 97
    let bodyWeight: Double = 74.0
    let bodyFat: Double = 22.5
    let vo2Max: Double = 42.5

    // MARK: - 周历史数据
    var weeklySteps: [DailyMetric] {
        let calendar = Calendar.current
        let today = Date()
        return (0..<7).map { dayOffset in
            let date = calendar.date(byAdding: .day, value: -6 + dayOffset, to: calendar.startOfDay(for: today))!
            let values: [Double] = [6200, 8100, 7500, 9200, 5800, 10500, 8432]
            return DailyMetric(date: date, value: values[dayOffset])
        }
    }

    var weeklyHeartRate: [DailyMetric] {
        let calendar = Calendar.current
        let today = Date()
        return (0..<7).map { dayOffset in
            let date = calendar.date(byAdding: .day, value: -6 + dayOffset, to: calendar.startOfDay(for: today))!
            let values: [Double] = [70, 73, 68, 75, 71, 69, 72]
            return DailyMetric(date: date, value: values[dayOffset])
        }
    }

    var weeklySleep: [DailyMetric] {
        let calendar = Calendar.current
        let today = Date()
        return (0..<7).map { dayOffset in
            let date = calendar.date(byAdding: .day, value: -6 + dayOffset, to: calendar.startOfDay(for: today))!
            let values: [Double] = [6.5, 7.8, 7.1, 6.2, 8.0, 7.5, 7.2]
            return DailyMetric(date: date, value: values[dayOffset])
        }
    }

    var weeklyHRV: [DailyMetric] {
        let calendar = Calendar.current
        let today = Date()
        return (0..<7).map { dayOffset in
            let date = calendar.date(byAdding: .day, value: -6 + dayOffset, to: calendar.startOfDay(for: today))!
            let values: [Double] = [48, 42, 55, 38, 50, 46, 45]
            return DailyMetric(date: date, value: values[dayOffset])
        }
    }

    var weeklyCalories: [DailyMetric] {
        let calendar = Calendar.current
        let today = Date()
        return (0..<7).map { dayOffset in
            let date = calendar.date(byAdding: .day, value: -6 + dayOffset, to: calendar.startOfDay(for: today))!
            let values: [Double] = [380, 520, 410, 600, 350, 480, 420]
            return DailyMetric(date: date, value: values[dayOffset])
        }
    }

    // MARK: - 最近锻炼
    var recentWorkouts: [WorkoutRecord] {
        let calendar = Calendar.current
        let now = Date()
        return [
            WorkoutRecord(
                id: UUID(),
                type: .running,
                startDate: calendar.date(byAdding: .hour, value: -3, to: now)!,
                endDate: calendar.date(byAdding: .hour, value: -2, to: now)!,
                durationMinutes: 42,
                calories: 380,
                distance: 5200,
                averageHeartRate: 148
            ),
            WorkoutRecord(
                id: UUID(),
                type: .strengthTraining,
                startDate: calendar.date(byAdding: .day, value: -1, to: now)!,
                endDate: calendar.date(byAdding: .day, value: -1, to: now)!.addingTimeInterval(3600),
                durationMinutes: 55,
                calories: 280,
                distance: nil,
                averageHeartRate: 125
            ),
            WorkoutRecord(
                id: UUID(),
                type: .cycling,
                startDate: calendar.date(byAdding: .day, value: -2, to: now)!,
                endDate: calendar.date(byAdding: .day, value: -2, to: now)!.addingTimeInterval(2700),
                durationMinutes: 45,
                calories: 420,
                distance: 12000,
                averageHeartRate: 138
            ),
            WorkoutRecord(
                id: UUID(),
                type: .yoga,
                startDate: calendar.date(byAdding: .day, value: -3, to: now)!,
                endDate: calendar.date(byAdding: .day, value: -3, to: now)!.addingTimeInterval(1800),
                durationMinutes: 30,
                calories: 120,
                distance: nil,
                averageHeartRate: 95
            ),
            WorkoutRecord(
                id: UUID(),
                type: .walking,
                startDate: calendar.date(byAdding: .day, value: -4, to: now)!,
                endDate: calendar.date(byAdding: .day, value: -4, to: now)!.addingTimeInterval(3000),
                durationMinutes: 50,
                calories: 180,
                distance: 3500,
                averageHeartRate: 105
            )
        ]
    }

    // MARK: - 睡眠阶段
    var sleepStages: [SleepStageSample] {
        let calendar = Calendar.current
        let today = Date()
        let bedtime = calendar.date(bySettingHour: 23, minute: 15, of: calendar.date(byAdding: .day, value: -1, to: today)!)!

        var stages: [SleepStageSample] = []
        var current = bedtime

        // 在床 10分钟
        stages.append(SleepStageSample(stage: .inBed, startDate: current, endDate: current.addingTimeInterval(600)))
        current = current.addingTimeInterval(600)

        // 核心睡眠 45分钟
        stages.append(SleepStageSample(stage: .core, startDate: current, endDate: current.addingTimeInterval(2700)))
        current = current.addingTimeInterval(2700)

        // 深睡 35分钟
        stages.append(SleepStageSample(stage: .deep, startDate: current, endDate: current.addingTimeInterval(2100)))
        current = current.addingTimeInterval(2100)

        // 核心睡眠 30分钟
        stages.append(SleepStageSample(stage: .core, startDate: current, endDate: current.addingTimeInterval(1800)))
        current = current.addingTimeInterval(1800)

        // REM 25分钟
        stages.append(SleepStageSample(stage: .rem, startDate: current, endDate: current.addingTimeInterval(1500)))
        current = current.addingTimeInterval(1500)

        // 清醒 5分钟
        stages.append(SleepStageSample(stage: .awake, startDate: current, endDate: current.addingTimeInterval(300)))
        current = current.addingTimeInterval(300)

        // 核心睡眠 40分钟
        stages.append(SleepStageSample(stage: .core, startDate: current, endDate: current.addingTimeInterval(2400)))
        current = current.addingTimeInterval(2400)

        // 深睡 33分钟
        stages.append(SleepStageSample(stage: .deep, startDate: current, endDate: current.addingTimeInterval(1980)))
        current = current.addingTimeInterval(1980)

        // REM 30分钟
        stages.append(SleepStageSample(stage: .rem, startDate: current, endDate: current.addingTimeInterval(1800)))
        current = current.addingTimeInterval(1800)

        // 核心睡眠 35分钟
        stages.append(SleepStageSample(stage: .core, startDate: current, endDate: current.addingTimeInterval(2100)))
        current = current.addingTimeInterval(2100)

        // REM 40分钟
        stages.append(SleepStageSample(stage: .rem, startDate: current, endDate: current.addingTimeInterval(2400)))
        current = current.addingTimeInterval(2400)

        // 清醒 10分钟
        stages.append(SleepStageSample(stage: .awake, startDate: current, endDate: current.addingTimeInterval(600)))

        return stages
    }

    // MARK: - 用药
    var medications: [Medication] {
        [
            Medication(
                name: "维生素D3",
                dosage: "1000 IU",
                route: .oral,
                frequency: .daily,
                notes: "早餐后服用",
                colorIndex: 0,
                reminderTimes: [Calendar.current.date(bySettingHour: 8, minute: 0, of: Date())!]
            ),
            Medication(
                name: "鱼油",
                dosage: "1000mg",
                route: .oral,
                frequency: .daily,
                notes: "随餐服用",
                colorIndex: 2,
                reminderTimes: [Calendar.current.date(bySettingHour: 12, minute: 30, of: Date())!]
            ),
            Medication(
                name: "镁片",
                dosage: "200mg",
                route: .oral,
                frequency: .daily,
                notes: "睡前服用，帮助睡眠",
                colorIndex: 3,
                reminderTimes: [Calendar.current.date(bySettingHour: 22, minute: 0, of: Date())!]
            )
        ]
    }

    // MARK: - 日志
    var journalEntries: [JournalEntry] {
        let calendar = Calendar.current
        return [
            JournalEntry(
                title: "晨跑感觉不错",
                content: "今天早上跑了5公里，配速6分30秒。跑完后精神状态很好，全天精力充沛。",
                date: calendar.date(byAdding: .hour, value: -5, to: Date())!,
                tags: ["跑步", "晨练"],
                painLevel: 1,
                mood: .veryGood,
                symptoms: []
            ),
            JournalEntry(
                title: "睡眠质量一般",
                content: "昨晚入睡比较困难，大概躺了40分钟才睡着。可能是因为下午喝了咖啡。",
                date: calendar.date(byAdding: .day, value: -1, to: Date())!,
                tags: ["睡眠", "咖啡"],
                painLevel: nil,
                mood: .neutral,
                symptoms: ["疲劳"]
            ),
            JournalEntry(
                title: "力量训练日",
                content: "今天练了胸和三头。卧推60kg做了4组8次，感觉状态不错。",
                date: calendar.date(byAdding: .day, value: -2, to: Date())!,
                tags: ["力量训练", "胸"],
                painLevel: 2,
                mood: .good,
                symptoms: ["肌肉酸痛"]
            )
        ]
    }

    // MARK: - 心情
    var moodEntries: [MoodEntry] {
        let calendar = Calendar.current
        return [
            MoodEntry(
                date: calendar.date(byAdding: .hour, value: -3, to: Date())!,
                mood: .good,
                valence: 0.5,
                emotion: .content,
                associations: [.fitness, .health],
                note: "跑完步后心情很好"
            ),
            MoodEntry(
                date: calendar.date(byAdding: .day, value: -1, to: Date())!,
                mood: .neutral,
                valence: 0.0,
                emotion: .tired,
                associations: [.sleep, .work],
                note: "工作有点累"
            ),
            MoodEntry(
                date: calendar.date(byAdding: .day, value: -2, to: Date())!,
                mood: .veryGood,
                valence: 0.7,
                emotion: .happy,
                associations: [.family, .food],
                note: "和家人一起吃了好吃的"
            )
        ]
    }
}
