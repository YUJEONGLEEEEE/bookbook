import Foundation
import UserNotifications

// 시스템 로컬 푸시(UNUserNotificationCenter) + 앱 내 알림함 기록을 함께 처리
enum NotificationManager {
    private static let reminderId = "reading.reminder.daily"
    private static let notifiedKey = "notifiedRewardCounts"
    private static let reminderEnabledKey = "readingReminderEnabled"
    private static let reminderHourKey = "readingReminderHour"
    private static let reminderMinuteKey = "readingReminderMinute"

    // MARK: - 권한

    static func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            print("알림 권한 허용: \(granted)")
        }
    }

    // MARK: - 책 획득 알림 (알림함 기록 + 시스템 푸시)

    static func sendBookReward(name: String) {
        let body = "‘\(name)’\(name.objectParticle) 획득했어요! 책탑이 한 칸 올라갔어요."
        NotificationStore.add(AppNotification(kind: .bookReward, title: "새 책 획득 🎉", body: body))
        fireLocalPush(title: "새 책 획득 🎉", body: body)
    }

    // 책한줄 작성 후 새로 획득한 책이 있으면 알림 (책탑쌓기 방문 없이도 즉시, 책당 1회)
    static func checkBookRewardAfterComment() {
        CoreDataManager.shared.fetchComments { comments in
            let earned = BookReward.earned(for: comments.count)
            var notified = Set(UserDefaults.standard.array(forKey: notifiedKey) as? [Int] ?? [])
            let fresh = earned.filter { !notified.contains($0.count) }
            guard !fresh.isEmpty else { return }
            for reward in fresh {
                sendBookReward(name: reward.name)
                notified.insert(reward.count)
            }
            UserDefaults.standard.set(Array(notified), forKey: notifiedKey)
        }
    }

    private static func fireLocalPush(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    // 회원탈퇴 시 알림 데이터 전체 초기화
    static func resetAll() {
        NotificationStore.clear()
        UserDefaults.standard.removeObject(forKey: notifiedKey)
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [reminderId])
        UserDefaults.standard.set(false, forKey: reminderEnabledKey)
    }

    // MARK: - 독서 리마인더 (매일 반복)

    static var isReminderOn: Bool { UserDefaults.standard.bool(forKey: reminderEnabledKey) }
    static var reminderHour: Int { UserDefaults.standard.object(forKey: reminderHourKey) as? Int ?? 20 }
    static var reminderMinute: Int { UserDefaults.standard.object(forKey: reminderMinuteKey) as? Int ?? 0 }

    static func setReminder(enabled: Bool, hour: Int, minute: Int) {
        UserDefaults.standard.set(enabled, forKey: reminderEnabledKey)
        UserDefaults.standard.set(hour, forKey: reminderHourKey)
        UserDefaults.standard.set(minute, forKey: reminderMinuteKey)

        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [reminderId])
        guard enabled else { return }

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let content = UNMutableNotificationContent()
        content.title = "오늘의 독서 📖"
        content.body = "책한줄을 작성하고 책탑을 쌓아보세요!"
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: reminderId, content: content, trigger: trigger)
        center.add(request)
    }
}
