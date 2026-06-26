
import Foundation

enum AgeRange: Int16 {
    case child = 0
    case teen = 1
    case adult = 2
    case senior = 3

    var title: String {
        switch self {
        case .child: return "어린이"
        case .teen: return "청소년"
        case .adult: return "성인"
        case .senior: return "노인"
        }
    }
}
