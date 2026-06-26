
import Foundation

enum Gender: String {
    case male
    case female

    var title: String {
        switch self {
        case .male: return "남자"
        case .female: return "여자"
        }
    }
}
