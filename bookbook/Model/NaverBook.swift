
import Foundation

struct naverBookInfo: Decodable {
    let item: [NaverBook]
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
