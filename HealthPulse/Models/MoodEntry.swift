import Foundation
import SwiftUI

// MARK: - 心情记录条目
struct MoodEntry: Identifiable, Codable, Equatable {
    let id: UUID
    var date: Date
    var mood: MoodLevel
    var valence: Double // -1.0 到 +1.0，对标 Apple State of Mind
    var emotion: EmotionType
    var associations: [LifeAssociation]
    var note: String

    init(date: Date = Date(), mood: MoodLevel = .neutral,
         valence: Double = 0, emotion: EmotionType = .calm,
         associations: [LifeAssociation] = [], note: String = "") {
        self.id = UUID()
        self.date = date
        self.mood = mood
        self.valence = valence
        self.emotion = emotion
        self.associations = associations
        self.note = note
    }

    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M月d日 HH:mm"
        return formatter.string(from: date)
    }
}

// MARK: - 情绪类型（对标 Apple State of Mind 的 38 种情绪，这里精选常用）
enum EmotionType: String, Codable, CaseIterable, Identifiable {
    // 非常愉悦
    case joyful = "喜悦"
    case excited = "兴奋"
    case proud = "自豪"
    case grateful = "感恩"
    case loved = "被爱"
    case peaceful = "平静"
    case content = "满足"
    case happy = "开心"
    case hopeful = "充满希望"
    case motivated = "有动力"

    // 中性
    case calm = "淡定"
    case neutral = "平静"
    case tired = "疲惫"
    case bored = "无聊"
    case distracted = "分心"

    // 不悦
    case sad = "悲伤"
    case anxious = "焦虑"
    case angry = "愤怒"
    case frustrated = "挫败"
    case stressed = "压力大"
    case lonely = "孤独"
    case overwhelmed = "不知所措"
    case disappointed = "失望"
    case guilty = "内疚"
    case afraid = "害怕"
    case irritable = "易怒"

    var id: String { rawValue }

    var emoji: String {
        switch self {
        case .joyful: return "🎉"
        case .excited: return "🤩"
        case .proud: return "😤"
        case .grateful: return "🙏"
        case .loved: return "🥰"
        case .peaceful: return "😌"
        case .content: return "😊"
        case .happy: return "😄"
        case .hopeful: return "🌟"
        case .motivated: return "💪"
        case .calm: return "😐"
        case .neutral: return "😶"
        case .tired: return "😴"
        case .bored: return "🥱"
        case .distracted: return "😵‍💫"
        case .sad: return "😢"
        case .anxious: return "😰"
        case .angry: return "😠"
        case .frustrated: return "😤"
        case .stressed: return "😫"
        case .lonely: return "😔"
        case .overwhelmed: return "😱"
        case .disappointed: return "😞"
        case .guilty: return "😳"
        case .afraid: return "😨"
        case .irritable: return "😡"
        }
    }

    var isPositive: Bool {
        valence >= 0.3
    }

    var valence: Double {
        switch self {
        case .joyful, .excited, .proud, .grateful, .loved, .peaceful,
             .content, .happy, .hopeful, .motivated:
            return 0.6
        case .calm, .neutral, .tired, .bored, .distracted:
            return 0.0
        case .sad, .anxious, .angry, .frustrated, .stressed, .lonely,
             .overwhelmed, .disappointed, .guilty, .afraid, .irritable:
            return -0.6
        }
    }
}

// MARK: - 生活关联（对标 Apple State of Mind 的 associations）
enum LifeAssociation: String, Codable, CaseIterable, Identifiable {
    case family = "家庭"
    case friends = "朋友"
    case partner = "伴侣"
    case work = "工作"
    case school = "学业"
    case health = "健康"
    case fitness = "健身"
    case sleep = "睡眠"
    case money = "财务"
    case travel = "旅行"
    case food = "饮食"
    case hobbies = "爱好"
    case weather = "天气"
    case news = "新闻"
    case socialMedia = "社交媒体"
    case selfCare = "自我关怀"
    case spirituality = "精神世界"
    case pets = "宠物"
    case home = "居家"
    case commute = "通勤"

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .family: return "house.fill"
        case .friends: return "person.2.fill"
        case .partner: return "heart.fill"
        case .work: return "briefcase.fill"
        case .school: return "graduationcap.fill"
        case .health: return "heart.text.square.fill"
        case .fitness: return "figure.run"
        case .sleep: return "bed.double.fill"
        case .money: return "dollarsign.circle.fill"
        case .travel: return "airplane"
        case .food: return "fork.knife"
        case .hobbies: return "gamecontroller.fill"
        case .weather: return "cloud.sun.fill"
        case .news: return "newspaper.fill"
        case .socialMedia: return "message.fill"
        case .selfCare: return "sparkles"
        case .spirituality: return "moon.stars.fill"
        case .pets: return "pawprint.fill"
        case .home: return "home.fill"
        case .commute: return "car.fill"
        }
    }
}

// MARK: - 心理量表
enum MentalHealthScale: String, CaseIterable, Identifiable {
    case gad7 = "GAD-7 焦虑量表"
    case phq9 = "PHQ-9 抑郁量表"

    var id: String { rawValue }

    var questions: [String] {
        switch self {
        case .gad7:
            return [
                "感觉紧张、焦虑或急切",
                "无法停止或控制担忧",
                "对各种各样的事情担忧过多",
                "很难放松下来",
                "由于不安而无法静坐",
                "变得容易烦恼或急躁",
                "感到似乎有什么可怕的事情会发生"
            ]
        case .phq9:
            return [
                "做事时提不起劲或没有兴趣",
                "感到心情低落、沮丧或绝望",
                "入睡困难、睡不安稳或睡眠过多",
                "感觉疲倦或没有活力",
                "食欲不振或吃太多",
                "觉得自己很糟，或觉得自己很失败，或让自己或家人失望",
                "对事物专注有困难，例如阅读报纸或看电视时",
                "动作或说话速度缓慢到别人已经察觉？或正好相反，烦躁或坐立不安、动来动去",
                "有不如死掉或用某种方式伤害自己的念头"
            ]
        }
    }

    var scoreRange: ClosedRange<Int> {
        switch self {
        case .gad7: return 0...21
        case .phq9: return 0...27
        }
    }

    func interpretation(score: Int) -> (level: String, color: Color, advice: String) {
        switch self {
        case .gad7:
            switch score {
            case 0...4: return ("轻微", .hpGreen, "焦虑水平较低，继续保持良好的生活方式。")
            case 5...9: return ("轻度", .hpBlue, "存在轻度焦虑，建议关注压力来源，适当放松。")
            case 10...14: return ("中度", .hpOrange, "中度焦虑，建议寻求专业心理咨询支持。")
            case 15...21: return ("重度", .hpRed, "重度焦虑，强烈建议尽快就医或寻求专业帮助。")
            default: return ("未知", .hpGray, "")
            }
        case .phq9:
            switch score {
            case 0...4: return ("无抑郁", .hpGreen, "情绪状态良好，继续保持。")
            case 5...9: return ("轻度", .hpBlue, "轻度抑郁情绪，建议关注情绪变化，增加社交和运动。")
            case 10...14: return ("中度", .hpOrange, "中度抑郁，建议寻求专业心理咨询。")
            case 15...19: return ("中重度", .hpOrange, "中重度抑郁，建议尽快就医。")
            case 20...27: return ("重度", .hpRed, "重度抑郁，请立即寻求专业医疗帮助。")
            default: return ("未知", .hpGray, "")
            }
        }
    }
}
