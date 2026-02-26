
import Foundation

enum BookSortOption: String, CaseIterable {
    case accuracy = "정확도순"
    case recommend = "추천순"
    case latest = "최신순"

    var apiValue: String? {
        switch self {
        case .accuracy: return "Accuracy"
        case .recommend: return nil
        case .latest: return "PublishDate"
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
