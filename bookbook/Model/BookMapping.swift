
import Foundation
import CoreData

extension BookData {
    func toEntity(context: NSManagedObjectContext) -> Book {
        let request: NSFetchRequest<Book> = Book.fetchRequest()
        request.predicate = NSPredicate(format: "title == %@", self.title)

        if let existingBook = try? context.fetch(request).first {
            return existingBook
        }

        let book = Book(context: context)
        book.isbn13 = self.isbn13
        book.title = self.title
        book.author = self.author
        book.image = self.cover
        book.publisher = self.publisher
        book.story = self.description
        book.searchCategoryId = Int64(self.searchCategoryId)

        return book
    }
}

extension NaverBook {
    func toEntity(context: NSManagedObjectContext) -> Book {
        let request: NSFetchRequest<Book> = Book.fetchRequest()
        request.predicate = NSPredicate(format: "title == %@", self.title)

        if let existingBook = try? context.fetch(request).first {
            return existingBook
        }

        let book = Book(context: context)
        book.isbn13 = self.isbn
        book.title = self.title
        book.author = self.author
        book.image = self.image
        book.publisher = self.publisher
        book.story = self.description

        return book
    }
}
