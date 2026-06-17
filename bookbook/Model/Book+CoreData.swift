
import Foundation
import CoreData

extension Book {

    public var id: String { UUID().uuidString }

    // Liked 관계를 통해 liked 상태 + 카운트 확인
    var isLiked: Bool {
        (liked != nil)
    }

//    좋아요 개수 가져오기
    var likedCount: Int {
        Int(liked?.likedCount ?? 0)
    }
}
