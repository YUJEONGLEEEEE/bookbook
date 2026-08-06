
import Foundation

protocol ISBNConvertible {
    var isbn13Int: Int { get }
}

extension BookData: ISBNConvertible {
    var isbn13Int: Int {
         Int(self.isbn13) ?? 0
    }
}

extension Book: ISBNConvertible {
    var isbn13Int: Int {
         Int(self.isbn13 ?? "") ?? 0
    }
}
