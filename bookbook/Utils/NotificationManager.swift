import Foundation
import UserNotifications

enum NotificationManager {
    private static var notifiedKey: String { UserSession.scopedKey("notifiedRewardCounts") }
    private static let reminderEnabledKey = "readingReminderEnabled"
    private static let reminderHourKey = "readingReminderHour"
    private static let reminderMinuteKey = "readingReminderMinute"
    private static let reminderWeekdaysKey = "readingReminderWeekdays"
    private static let reminderTimesKey = "readingReminderTimes"

    // MARK: - 권한

    static func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in }
    }

    static func ensureAuthorization(completion: @escaping (Bool) -> Void) {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .authorized, .provisional, .ephemeral:
                DispatchQueue.main.async { completion(true) }
            case .denied:
                DispatchQueue.main.async { completion(false) }
            case .notDetermined:
                center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
                    DispatchQueue.main.async { completion(granted) }
                }
            @unknown default:
                DispatchQueue.main.async { completion(false) }
            }
        }
    }

    // MARK: - 책 획득 알림 (알림함 기록 + 시스템 푸시)

    static func sendBookReward(name: String) {
        let title = "책한줄 목표 달성! 🥳"
        let body = "‘\(name)’\(name.objectParticle) 획득했어요. 지금 책탑을 확인해보세요."
        NotificationStore.add(AppNotification(kind: .bookReward, title: title, body: body))
        fireLocalPush(title: title, body: body,
                      userInfo: ["kind": AppNotificationKind.bookReward.rawValue])
    }

    static func checkBookRewardAfterComment() {
        CoreDataManager.shared.fetchComments { comments in
            let earned = BookReward.earned(for: comments.count)
            var notified = Set(UserDefaults.standard.array(forKey: notifiedKey) as? [String] ?? [])
            let fresh = earned.filter { !notified.contains($0.imageName) }
            guard !fresh.isEmpty else { return }
            for reward in fresh {
                sendBookReward(name: reward.name)
                notified.insert(reward.imageName)
            }
            UserDefaults.standard.set(Array(notified), forKey: notifiedKey)
        }
    }

    static func syncRewardState() {
        CoreDataManager.shared.fetchComments { comments in
            let earned = BookReward.earned(for: comments.count)
            let earnedImageNames = Set(earned.map { $0.imageName })
            let notified = Set(UserDefaults.standard.array(forKey: notifiedKey) as? [String] ?? [])
            UserDefaults.standard.set(Array(notified.intersection(earnedImageNames)), forKey: notifiedKey)
            LevelRewardStore.retain(Set(earned.map { $0.count }))
        }
    }

    private static func fireLocalPush(title: String, body: String, userInfo: [AnyHashable: Any] = [:]) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.userInfo = userInfo
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    static func clearAccountState() {
        NotificationStore.clear()
        UserDefaults.standard.removeObject(forKey: notifiedKey)
    }

    static func clearReminders() {
        [reminderTimesKey, reminderWeekdaysKey, reminderHourKey, reminderMinuteKey]
            .forEach { UserDefaults.standard.removeObject(forKey: $0) }
        UserDefaults.standard.set(false, forKey: reminderEnabledKey)
        clearScheduledReminders()
    }

    // MARK: - 독서 리마인더 (선택 요일 × 하루 여러 번)

    static var isReminderOn: Bool { UserDefaults.standard.bool(forKey: reminderEnabledKey) }
    static var reminderHour: Int { UserDefaults.standard.object(forKey: reminderHourKey) as? Int ?? 20 }
    static var reminderMinute: Int { UserDefaults.standard.object(forKey: reminderMinuteKey) as? Int ?? 0 }

    static var reminderWeekdays: Set<Int> {
        if let arr = UserDefaults.standard.array(forKey: reminderWeekdaysKey) as? [Int] { return Set(arr) }
        return Set(1...7)
    }

    static var reminderTimes: [Int] {
        if let arr = UserDefaults.standard.array(forKey: reminderTimesKey) as? [Int], !arr.isEmpty { return arr }
        return [reminderHour * 60 + reminderMinute]
    }

    static func setReminder(enabled: Bool, times: [Int], weekdays: Set<Int>) {
        UserDefaults.standard.set(enabled, forKey: reminderEnabledKey)
        UserDefaults.standard.set(times, forKey: reminderTimesKey)
        UserDefaults.standard.set(Array(weekdays), forKey: reminderWeekdaysKey)

        clearScheduledReminders {
            guard enabled, !weekdays.isEmpty, !times.isEmpty else { return }
            let content = UNMutableNotificationContent()
            content.title = "오늘의 독서 📖"
            content.body = "책한줄을 작성하고 책탑을 쌓아보세요!"
            content.sound = .default

            let center = UNUserNotificationCenter.current()
            for weekday in weekdays {
                for (index, minutes) in times.enumerated() {
                    var comps = DateComponents()
                    comps.weekday = weekday
                    comps.hour = minutes / 60
                    comps.minute = minutes % 60
                    let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)
                    let request = UNNotificationRequest(identifier: "reading.reminder.\(weekday).\(index)",
                                                        content: content, trigger: trigger)
                    center.add(request)
                }
            }
        }
    }

    private static func clearScheduledReminders(then completion: (() -> Void)? = nil) {
        let center = UNUserNotificationCenter.current()
        center.getPendingNotificationRequests { requests in
            let ids = requests.map { $0.identifier }.filter { $0.hasPrefix("reading.reminder") }
            if !ids.isEmpty { center.removePendingNotificationRequests(withIdentifiers: ids) }
            completion?()
        }
    }
}
