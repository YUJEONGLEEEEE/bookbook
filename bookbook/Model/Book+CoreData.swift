
import Foundation
import CoreData

extension Book {

    public var id: String { UUID().uuidString }

    var isLiked: Bool {
        (liked != nil)
    }

    var likedCount: Int {
        Int(liked?.likedCount ?? 0)
    }
}
