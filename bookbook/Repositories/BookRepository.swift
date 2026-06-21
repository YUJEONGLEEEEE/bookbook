import Foundation
import CoreData

class BookRepository {
    static let shared = BookRepository()

    private let persistentContainer: NSPersistentContainer

    init(container: NSPersistentContainer = CoreDataManager.shared.persistentContainer) {
        self.persistentContainer = container
    }

    // MARK: - Fetch

    func getTopRankedBooks() -> [Book] {
        let context = persistentContainer.viewContext
        let request: NSFetchRequest<Book> = Book.fetchRequest()

        request.predicate = NSPredicate(format: "liked != nil")

        request.sortDescriptors = [
            NSSortDescriptor(key: "liked.likedCount", ascending: false)
        ]
        request.fetchLimit = 3

        return (try? context.fetch(request)) ?? []
    }

    // MARK: - Demo Seed

    /// 데모용: 좋아요 랭킹을 채우기 위해 몇 권의 책에 랜덤 좋아요 수를 부여한다.
    /// (백엔드가 없어 전체 사용자 좋아요 집계가 없으므로, 처음 한 번만 시드해 랭킹 섹션이 보이게 한다.)
    func seedDemoRankedBooksIfNeeded() {
        let context = persistentContainer.viewContext

        let likedRequest: NSFetchRequest<Liked> = Liked.fetchRequest()
        likedRequest.predicate = NSPredicate(format: "book != nil")
        if ((try? context.count(for: likedRequest)) ?? 0) > 0 { return }

        let demoBooks: [(isbn: Int64, title: String, author: String, publisher: String, image: String, likes: Int64)] = [
            (9788937460449, "데미안", "헤르만 헤세", "민음사", "https://image.aladin.co.kr/product/26/0/coversum/s452139198_1.jpg", 92),
            (9788937460777, "1984", "조지 오웰", "민음사", "https://image.aladin.co.kr/product/41/89/coversum/s122531356_2.jpg", 78),
            (9788932917245, "어린 왕자", "생텍쥐페리", "열린책들", "https://image.aladin.co.kr/product/6853/49/coversum/8932917248_2.jpg", 64),
        ]

        for item in demoBooks {
            let book = Book(context: context)
            book.isbn13 = String(item.isbn)
            book.title = item.title
            book.author = item.author
            book.publisher = item.publisher
            book.image = item.image

            let liked = Liked(context: context)
            liked.isbn13 = item.isbn
            liked.likedCount = item.likes
            liked.createdAt = Date()
            liked.book = book
        }

        do {
            try context.save()
        } catch {
            debugLog("데모 랭킹 시드 실패: \(error)")
        }
    }
}
