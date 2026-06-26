import Foundation

extension Notification.Name {
    static let appNotificationsDidChange = Notification.Name("appNotificationsDidChange")
}

enum NotificationStore {
    private static var key: String { UserSession.scopedKey("appNotifications") }
    private static let maxCount = 50

    static func all() -> [AppNotification] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let list = try? JSONDecoder().decode([AppNotification].self, from: data) else { return [] }
        return list.sorted { $0.date > $1.date }
    }

    static var unreadCount: Int {
        all().filter { !$0.isRead }.count
    }

    static func add(_ notification: AppNotification) {
        var list = all()
        list.insert(notification, at: 0)
        if list.count > maxCount { list = Array(list.prefix(maxCount)) }
        save(list)
    }

    static func markAllRead() {
        var list = all()
        guard list.contains(where: { !$0.isRead }) else { return }
        for i in list.indices { list[i].isRead = true }
        save(list)
    }

    static func remove(id: UUID) {
        save(all().filter { $0.id != id })
    }

    static func clear() {
        save([])
    }

    private static func save(_ list: [AppNotification]) {
        if let data = try? JSONEncoder().encode(list) {
            UserDefaults.standard.set(data, forKey: key)
        }
        NotificationCenter.default.post(name: .appNotificationsDidChange, object: nil)
    }
}
