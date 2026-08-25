import Foundation
import SwiftUI

// MARK: - 用药记录
struct Medication: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var dosage: String
    var route: MedicationRoute
    var frequency: MedicationFrequency
    var notes: String
    var startDate: Date
    var isActive: Bool
    var reminderTimes: [Date]
    var colorIndex: Int

    init(name: String, dosage: String, route: MedicationRoute = .oral,
         frequency: MedicationFrequency = .daily, notes: String = "",
         startDate: Date = Date(), isActive: Bool = true,
         reminderTimes: [Date] = [], colorIndex: Int = 0) {
        self.id = UUID()
        self.name = name
        self.dosage = dosage
        self.route = route
        self.frequency = frequency
        self.notes = notes
        self.startDate = startDate
        self.isActive = isActive
        self.reminderTimes = reminderTimes
        self.colorIndex = colorIndex
    }

    var frequencyText: String {
        frequency.displayName
    }

    var routeText: String {
        route.displayName
    }
}

// MARK: - 给药途径
enum MedicationRoute: String, Codable, CaseIterable, Identifiable {
    case oral
    case topical
    case injection
    case inhalation
    case sublingual
    case rectal
    case other

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .oral: return "口服"
        case .topical: return "外用"
        case .injection: return "注射"
        case .inhalation: return "吸入"
        case .sublingual: return "舌下"
        case .rectal: return "直肠"
        case .other: return "其他"
        }
    }

    var systemImage: String {
        switch self {
        case .oral: return "pills.fill"
        case .topical: return "hand.raised.fill"
        case .injection: return "syringe.fill"
        case .inhalation: return "wind"
        case .sublingual: return "mouth.fill"
        case .rectal: return "circle.fill"
        case .other: return "pill.fill"
        }
    }
}

// MARK: - 用药频率
enum MedicationFrequency: String, Codable, CaseIterable, Identifiable {
    case daily
    case twiceDaily
    case threeTimesDaily
    case weekly
    case asNeeded
    case monthly
    case custom

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .daily: return "每日一次"
        case .twiceDaily: return "每日两次"
        case .threeTimesDaily: return "每日三次"
        case .weekly: return "每周一次"
        case .asNeeded: return "按需"
        case .monthly: return "每月一次"
        case .custom: return "自定义"
        }
    }

    var timesPerDay: Int {
        switch self {
        case .daily: return 1
        case .twiceDaily: return 2
        case .threeTimesDaily: return 3
        case .weekly, .monthly, .asNeeded, .custom: return 0
        }
    }
}

// MARK: - 用药颜色
extension Medication {
    var accentColor: Color {
        let colors: [Color] = [
            .hpBlue, .hpGreen, .hpOrange, .hpPurple,
            .hpPink, .hpTeal, .hpRed, .hpIndigo
        ]
        return colors[colorIndex % colors.count]
    }
}
