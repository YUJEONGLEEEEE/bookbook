
import Foundation
import CoreData

extension BookData {
    func toEntity(context: NSManagedObjectContext) -> Book {
        // 중복 체크 (중요!)
        let request: NSFetchRequest<Book> = Book.fetchRequest()
        request.predicate = NSPredicate(format: "title == %@", self.title)

        if let existingBook = try? context.fetch(request).first {
            return existingBook
        }

        // 새로운 Book 생성
        let book = Book(context: context)
        book.title = self.title
        book.author = self.author
        book.image = self.cover  // API의 cover → Book의 image
        book.publisher = self.publisher
        book.story = self.description  // API의 description → Book의 story

        return book
    }
}

extension NaverBookData {
    func toEntity(context: NSManagedObjectContext) -> Book {
        // 중복 체크
        let request: NSFetchRequest<Book> = Book.fetchRequest()
        request.predicate = NSPredicate(format: "title == %@", self.title)

        if let existingBook = try? context.fetch(request).first {
            return existingBook
        }

        // 새로운 Book 생성
        let book = Book(context: context)
        book.title = self.title
        book.author = self.author
        book.image = self.image
        book.publisher = self.publisher
        book.story = self.description

        return book
    }
}
