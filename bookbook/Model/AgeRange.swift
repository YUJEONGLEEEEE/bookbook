
import Foundation

enum AgeRange: Int16 {
    case child = 0
    case teen = 1
    case adult = 2
    case senior = 3

    // 내 취향 화면 등에서 보여줄 한글 표기 (연령 선택 화면 버튼 문구와 동일)
    var title: String {
        switch self {
        case .child: return "어린이"
        case .teen: return "청소년"
        case .adult: return "성인"
        case .senior: return "노인"
        }
    }
}
