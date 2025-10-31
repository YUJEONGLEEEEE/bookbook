
import Foundation

struct BookInfo: Decodable {
    let totalResults: Int
    let item: [BookData]
}

struct BookData: Decodable {
    let title: String
    let author: String
    let pubDate: String
    let description: String
    let isbn: String
    let isbn13: Int
    let cover: String
    let publisher: String
}

struct naverBookInfo: Decodable {
    let item: [naverBookData]
}

struct naverBookData: Decodable {
    let title: String
    let image: String
    let author: String
    let publisher: String
    let pubdate: String
    let isbn: String
    let description: String
}
