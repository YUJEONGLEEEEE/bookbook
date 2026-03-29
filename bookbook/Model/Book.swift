
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
    let isbn13: String
    let cover: String
    let publisher: String
    let searchCategoryId: Int

//   로컬에서만 사용
    var categoryId: Int64 = 0
    var likedCount: Int = 0
    var isBookmarked: Bool = false
}
