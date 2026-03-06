
import Foundation
import CoreData

extension Book: Identifiable {

    public var id: String { UUID().uuidString }

    // Liked 관계를 통해 liked 상태 확인
    var isLiked: Bool {
        (liked != nil)
    }
}

struct BookViewModel {
    let title: String
    let author: String
    let image: String
    let publisher: String
    let story: String

    init(from book: Book) {
        self.title = book.title ?? ""
        self.author = book.author ?? ""
        self.image = book.image ?? ""
        self.publisher = book.publisher ?? ""
        self.story = book.story ?? ""
    }
}
