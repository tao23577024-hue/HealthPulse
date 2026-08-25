import Foundation
import UserNotifications
import UIKit

/// 本地通知管理器 — 用药提醒、健康提醒等
final class NotificationManager {

    private let center = UNUserNotificationCenter.current()

    func requestPermissions() {
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("通知权限已授予")
            }
        }
    }

    // MARK: - 用药提醒
    func scheduleMedicationReminders(_ medications: [Medication]) {
        // 先取消所有现有用药提醒
        center.removePendingNotificationRequests(withIdentifiers: medications.map { "med-\($0.id.uuidString)" })

        for medication in medications {
            guard medication.isActive else { continue }

            for (index, time) in medication.reminderTimes.enumerated() {
                let content = UNMutableNotificationContent()
                content.title = "用药提醒"
                content.body = "该服用 \(medication.name) \(medication.dosage) 了"
                content.sound = .default
                content.categoryIdentifier = "MEDICATION_REMINDER"

                var dateComponents = Calendar.current.dateComponents([.hour, .minute], from: time)
                dateComponents.second = 0

                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                let identifier = "med-\(medication.id.uuidString)-\(index)"
                let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

                center.add(request)
            }
        }
    }

    // MARK: - 通用提醒
    func scheduleDailyReminder(title: String, body: String, hour: Int, minute: Int, identifier: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        center.add(request)
    }

    // MARK: - 取消提醒
    func cancelReminder(identifier: String) {
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
    }

    func cancelAllReminders() {
        center.removeAllPendingNotificationRequests()
    }

    // MARK: - 立即发送通知
    func sendImmediateNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        center.add(request)
    }

    // MARK: - 徽章管理
    func setBadgeCount(_ count: Int) {
        DispatchQueue.main.async {
            UIApplication.shared.applicationIconBadgeNumber = count
        }
    }

    func clearBadge() {
        setBadgeCount(0)
    }
}
