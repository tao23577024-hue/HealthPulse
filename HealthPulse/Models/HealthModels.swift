import Foundation
import SwiftUI
import HealthKit

// MARK: - 每日指标数据点（用于图表）
struct DailyMetric: Identifiable, Codable, Equatable {
    let id = UUID()
    let date: Date
    let value: Double

    var dayLabel: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }

    var shortDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        return formatter.string(from: date)
    }
}

// MARK: - 今日健康指标汇总
struct TodayMetrics {
    var heartRate: Double = 0
    var restingHeartRate: Double = 0
    var hrv: Double = 0
    var steps: Int = 0
    var activeCalories: Double = 0
    var exerciseMinutes: Double = 0
    var standHours: Double = 0
    var bloodOxygen: Double = 0
    var bodyWeight: Double = 0
    var bodyFat: Double = 0
    var vo2Max: Double = 0
}

// MARK: - 睡眠数据
struct SleepData {
    var totalHours: Double = 0
    var deepMinutes: Double = 0
    var coreMinutes: Double = 0
    var remMinutes: Double = 0
    var awakeMinutes: Double = 0
    var inBedMinutes: Double = 0
    var efficiency: Double = 0
    var bedtime: Date?
    var wakeTime: Date?
    var stages: [SleepStageSample] = []
}

// MARK: - 睡眠阶段样本
struct SleepStageSample: Identifiable, Codable, Equatable {
    let id = UUID()
    let stage: SleepStage
    let startDate: Date
    let endDate: Date

    var durationMinutes: Double {
        endDate.timeIntervalSince(startDate) / 60
    }
}

// MARK: - 睡眠阶段枚举
enum SleepStage: String, Codable, CaseIterable, Identifiable {
    case awake
    case rem
    case core
    case deep
    case unspecified
    case inBed

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .awake: return "清醒"
        case .rem: return "REM"
        case .core: return "核心睡眠"
        case .deep: return "深睡"
        case .unspecified: return "睡眠"
        case .inBed: return "在床"
        }
    }

    var color: Color {
        switch self {
        case .awake: return .hpOrange
        case .rem: return .hpPurple
        case .core: return .hpBlue
        case .deep: return .hpIndigo
        case .unspecified: return .hpGray
        case .inBed: return .hpGray.opacity(0.5)
        }
    }
}

// MARK: - 锻炼记录
struct WorkoutRecord: Identifiable, Codable, Equatable {
    let id: UUID
    let type: WorkoutType
    let startDate: Date
    let endDate: Date
    let durationMinutes: Double
    let calories: Double
    let distance: Double?
    let averageHeartRate: Double?

    var durationString: String {
        if durationMinutes >= 60 {
            let hours = Int(durationMinutes) / 60
            let mins = Int(durationMinutes) % 60
            return "\(hours)小时\(mins)分钟"
        }
        return "\(Int(durationMinutes))分钟"
    }
}

// MARK: - 锻炼类型
enum WorkoutType: String, Codable, CaseIterable, Identifiable {
    case running
    case walking
    case cycling
    case swimming
    case strengthTraining
    case yoga
    case hiking
    case rowing
    case stairClimbing
    case other

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .running: return "跑步"
        case .walking: return "步行"
        case .cycling: return "骑行"
        case .swimming: return "游泳"
        case .strengthTraining: return "力量训练"
        case .yoga: return "瑜伽"
        case .hiking: return "徒步"
        case .rowing: return "划船"
        case .stairClimbing: return "爬楼"
        case .other: return "其他"
        }
    }

    var systemImage: String {
        switch self {
        case .running: return "figure.run"
        case .walking: return "figure.walk"
        case .cycling: return "figure.outdoor.cycle"
        case .swimming: return "figure.pool.swim"
        case .strengthTraining: return "dumbbell.fill"
        case .yoga: return "figure.yoga"
        case .hiking: return "mountain.2.fill"
        case .rowing: return "figure.rower"
        case .stairClimbing: return "staircase.fill"
        case .other: return "figure.mixed.cardio"
        }
    }

    var hkWorkoutActivityType: HKWorkoutActivityType {
        switch self {
        case .running: return .running
        case .walking: return .walking
        case .cycling: return .cycling
        case .swimming: return .swimming
        case .strengthTraining: return .traditionalStrengthTraining
        case .yoga: return .yoga
        case .hiking: return .hiking
        case .rowing: return .rowing
        case .stairClimbing: return .stairClimbing
        case .other: return .other
        }
    }
}

// MARK: - 周历史数据
struct WeeklyHistory {
    var steps: [DailyMetric] = []
    var heartRate: [DailyMetric] = []
    var sleep: [DailyMetric] = []
    var hrv: [DailyMetric] = []
    var calories: [DailyMetric] = []
}

// MARK: - 健康洞察
struct HealthInsight: Identifiable, Equatable {
    let id = UUID()
    let type: InsightType
    let title: String
    let message: String
    let severity: InsightSeverity
    let evidence: String

    var systemImage: String {
        switch type {
        case .heartRate: return "heart.fill"
        case .sleep: return "bed.double.fill"
        case .activity: return "figure.run"
        case .recovery: return "waveform.path.ecg"
        case .nutrition: return "fork.knife"
        case .general: return "lightbulb.fill"
        }
    }
}

enum InsightType: Equatable {
    case heartRate
    case sleep
    case activity
    case recovery
    case nutrition
    case general
}

enum InsightSeverity: Equatable {
    case positive
    case neutral
    case warning
    case critical

    var color: Color {
        switch self {
        case .positive: return .hpGreen
        case .neutral: return .hpBlue
        case .warning: return .hpOrange
        case .critical: return .hpRed
        }
    }

    var icon: String {
        switch self {
        case .positive: return "checkmark.circle.fill"
        case .neutral: return "info.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .critical: return "xmark.octagon.fill"
        }
    }
}
