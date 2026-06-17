
import Foundation

enum Gender: String {
    case male
    case female

    // 내 취향 화면 등에서 보여줄 한글 표기 (성별 선택 화면 버튼 문구와 동일)
    var title: String {
        switch self {
        case .male: return "남자"
        case .female: return "여자"
        }
    }
}
