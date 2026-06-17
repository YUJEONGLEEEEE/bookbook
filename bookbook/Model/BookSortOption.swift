
import Foundation

enum BookSortOption: String, CaseIterable {
    case accuracy = "정확도순"
    case recommend = "추천순"
    case latest = "최신순"

    var apiValue: String? {
        switch self {
        case .accuracy: return "Accuracy"
        case .recommend: return "SalesPoint"   // 좋아요 누적 데이터가 없으므로 알라딘 판매량순으로 대체
        case .latest: return "PublishTime"
        }
    }

    var title: String {
        switch self {
        case .accuracy: return "정확도순"
        case .recommend: return "추천순"
        case .latest: return "최신순"
        }
    }
}
