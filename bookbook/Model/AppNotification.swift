import Foundation

enum AppNotificationKind: String, Codable {
    case bookReward   // 책탑쌓기 책 획득
    case reminder     // 독서 리마인더
    case like         // 마음(좋아요) 받음
    case notice       // 공지/이벤트
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
