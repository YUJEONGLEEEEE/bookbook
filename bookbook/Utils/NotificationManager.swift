import Foundation
import UserNotifications

// 시스템 로컬 푸시(UNUserNotificationCenter) + 앱 내 알림함 기록을 함께 처리
enum NotificationManager {
    private static let notifiedKey = "notifiedRewardCounts"
    private static let reminderEnabledKey = "readingReminderEnabled"
    private static let reminderHourKey = "readingReminderHour"
    private static let reminderMinuteKey = "readingReminderMinute"
    private static let reminderWeekdaysKey = "readingReminderWeekdays"
    private static let reminderTimesKey = "readingReminderTimes"   // 하루 여러 번: [분(0~1439)]

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
        // userInfo로 종류를 실어 탭 시 라우팅(책탑쌓기)에 사용
        fireLocalPush(title: "새 책 획득 🎉", body: body,
                      userInfo: ["kind": AppNotificationKind.bookReward.rawValue])
    }

    // 책한줄 작성 후 새로 획득한 책이 있으면 알림 (책탑쌓기 방문 없이도 즉시, 책당 1회)
    static func checkBookRewardAfterComment() {
        CoreDataManager.shared.fetchComments { comments in
            let earned = BookReward.earned(for: comments.count)
            // 책별 고유 식별자(imageName)로 dedup → 동일 count가 생겨도 안전
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

    // 책한줄 삭제 등으로 작성 수가 줄면, 더 이상 획득 상태가 아닌 책의 알림/연출 기록을 해제한다.
    // → 다시 임계치를 넘기면 재획득 알림·애니메이션·팝업이 정상적으로 다시 나옴.
    static func syncRewardState() {
        CoreDataManager.shared.fetchComments { comments in
            let earned = BookReward.earned(for: comments.count)
            let earnedImageNames = Set(earned.map { $0.imageName })
            // 알림 dedup 기록 정리 (현재 획득분만 유지)
            let notified = Set(UserDefaults.standard.array(forKey: notifiedKey) as? [String] ?? [])
            UserDefaults.standard.set(Array(notified.intersection(earnedImageNames)), forKey: notifiedKey)
            // 팝업/연출 확인 기록 정리
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

    // 회원탈퇴 시 알림 데이터 전체 초기화
    static func resetAll() {
        NotificationStore.clear()
        [notifiedKey, reminderTimesKey, reminderWeekdaysKey, reminderHourKey, reminderMinuteKey]
            .forEach { UserDefaults.standard.removeObject(forKey: $0) }
        UserDefaults.standard.set(false, forKey: reminderEnabledKey)
        clearScheduledReminders()
    }

    // MARK: - 독서 리마인더 (선택 요일 × 하루 여러 번)

    static var isReminderOn: Bool { UserDefaults.standard.bool(forKey: reminderEnabledKey) }
    static var reminderHour: Int { UserDefaults.standard.object(forKey: reminderHourKey) as? Int ?? 20 }
    static var reminderMinute: Int { UserDefaults.standard.object(forKey: reminderMinuteKey) as? Int ?? 0 }

    // 반복 요일 (Calendar 기준 1=일 ~ 7=토). 기본: 매일
    static var reminderWeekdays: Set<Int> {
        if let arr = UserDefaults.standard.array(forKey: reminderWeekdaysKey) as? [Int] { return Set(arr) }
        return Set(1...7)
    }

    // 하루 알림 시간들 (자정 기준 분). 기본: 기존 단일 시간 → 없으면 20:00
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
            // (선택 요일 × 하루 시간들) 조합마다 개별 반복 알림 등록
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

    // 예약된 리마인더(reading.reminder*) 전부 제거 (구버전 식별자 포함)
    private static func clearScheduledReminders(then completion: (() -> Void)? = nil) {
        let center = UNUserNotificationCenter.current()
        center.getPendingNotificationRequests { requests in
            let ids = requests.map { $0.identifier }.filter { $0.hasPrefix("reading.reminder") }
            if !ids.isEmpty { center.removePendingNotificationRequests(withIdentifiers: ids) }
            completion?()
        }
    }
}
