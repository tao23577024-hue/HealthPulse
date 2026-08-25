import Foundation
import SwiftUI

// MARK: - 健康日志条目
struct JournalEntry: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var content: String
    var date: Date
    var tags: [String]
    var painLevel: Int? // 0-10 疼痛量表
    var mood: MoodLevel?
    var symptoms: [String]

    init(title: String, content: String, date: Date = Date(),
         tags: [String] = [], painLevel: Int? = nil,
         mood: MoodLevel? = nil, symptoms: [String] = []) {
        self.id = UUID()
        self.title = title
        self.content = content
        self.date = date
        self.tags = tags
        self.painLevel = painLevel
        self.mood = mood
        self.symptoms = symptoms
    }

    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月d日 HH:mm"
        return formatter.string(from: date)
    }

    var relativeDateString: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - 心情等级
enum MoodLevel: Int, Codable, CaseIterable, Identifiable {
    case veryBad = 1
    case bad = 2
    case neutral = 3
    case good = 4
    case veryGood = 5

    var id: Int { rawValue }

    var displayName: String {
        switch self {
        case .veryBad: return "很差"
        case .bad: return "较差"
        case .neutral: return "一般"
        case .good: return "较好"
        case .veryGood: return "很好"
        }
    }

    var emoji: String {
        switch self {
        case .veryBad: return "😫"
        case .bad: return "😔"
        case .neutral: return "😐"
        case .good: return "🙂"
        case .veryGood: return "😄"
        }
    }

    var color: Color {
        switch self {
        case .veryBad: return .hpRed
        case .bad: return .hpOrange
        case .neutral: return .hpGray
        case .good: return .hpGreen
        case .veryGood: return .hpTeal
        }
    }
}

// MARK: - 常见症状预设
enum CommonSymptom: String, CaseIterable, Identifiable {
    case headache = "头痛"
    case fatigue = "疲劳"
    case insomnia = "失眠"
    case nausea = "恶心"
    case dizziness = "头晕"
    case stomachache = "腹痛"
    case musclePain = "肌肉酸痛"
    case jointPain = "关节痛"
    case cough = "咳嗽"
    case soreThroat = "咽痛"
    case fever = "发热"
    case chills = "发冷"
    case shortnessOfBreath = "气短"
    case chestPain = "胸痛"
    case backPain = "背痛"
    case anxiety = "焦虑"
    case stress = "压力大"
    case lowMood = "情绪低落"
    case irritability = "易怒"
    case brainFog = "注意力不集中"

    var id: String { rawValue }
}
