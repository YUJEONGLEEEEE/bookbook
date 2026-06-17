
import Foundation

struct naverBookInfo: Decodable {
    let item: [NaverBook]

    // 네이버 책 검색 JSON의 결과 배열 키는 "items"이다.
    enum CodingKeys: String, CodingKey {
        case item = "items"
    }
}

struct NaverBook: Decodable {
    let title: String
    let image: String
    let author: String
    let publisher: String
    let pubdate: String
    let isbn: String
    let description: String

    private enum CodingKeys: String, CodingKey {
        case title, image, author, publisher, pubdate, isbn, description
    }
}
