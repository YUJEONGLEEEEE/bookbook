import Foundation

enum AppNotificationKind: String, Codable {
    case bookReward
    case reminder
    case like
    case notice
}

struct AppNotification: Codable {
    let id: UUID
    let kind: AppNotificationKind
    let title: String
    let body: String
    let date: Date
    var isRead: Bool

    init(kind: AppNotificationKind, title: String, body: String, date: Date = Date(), isRead: Bool = false) {
        self.id = UUID()
        self.kind = kind
        self.title = title
        self.body = body
        self.date = date
        self.isRead = isRead
    }
}
