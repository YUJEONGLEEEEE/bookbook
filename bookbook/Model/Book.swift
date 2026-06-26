
import Foundation

struct BookInfo: Decodable {
    let totalResults: Int
    var item: [BookData]

    enum CodingKeys: String, CodingKey {
        case totalResults, item
    }

    func filteringExcluded() -> BookInfo {
        var copy = self
        copy.item = item.filter { !$0.isExcluded }
        return copy
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        totalResults = (try? container.decode(Int.self, forKey: .totalResults)) ?? 0
        item = (try? container.decode([BookData].self, forKey: .item)) ?? []
    }
}

struct BookData: Decodable {
    let title: String
    let author: String
    let pubDate: String
    let description: String
    let isbn13: String
    let cover: String
    let publisher: String

    var searchCategoryId: Int = 0
    var categoryId: Int64 = 0
    var categoryName: String = ""
    var likedCount: Int = 0
    var isBookmarked: Bool = false

    enum CodingKeys: String, CodingKey {
        case title, author, pubDate, description, isbn13, cover, publisher, categoryName, categoryId
    }
}

extension BookData {
    static let excludedCategoryKeywords = [
        "고등학교참고서", "중학교참고서", "초등학교참고서", "교과서 수록도서",
        "성인/성애만화", "달력/기타", "잡지", "수험서/자격증", "전집/중고전집"
    ]

    static let excludedCategoryIds: Set<Int64> = [181723, 181727]

    static let excludedTitleKeywords = ["세트", "전집"]
    static let volumeSetPatterns = [#"전\s*\d+\s*권"#, #"\d+\s*[~∼\-]\s*\d+\s*권"#]

    var isExcludedCategory: Bool {
        if BookData.excludedCategoryIds.contains(categoryId) { return true }
        return BookData.excludedCategoryKeywords.contains { categoryName.contains($0) }
    }
    var isSetBook: Bool {
        if BookData.excludedTitleKeywords.contains(where: { title.contains($0) }) { return true }
        return BookData.volumeSetPatterns.contains { title.range(of: $0, options: .regularExpression) != nil }
    }
    var isExcluded: Bool { isExcludedCategory || isSetBook }
}

extension BookData {
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        title = (try? c.decode(String.self, forKey: .title)) ?? ""
        author = (try? c.decode(String.self, forKey: .author)) ?? ""
        pubDate = (try? c.decode(String.self, forKey: .pubDate)) ?? ""
        description = (try? c.decode(String.self, forKey: .description)) ?? ""
        isbn13 = (try? c.decode(String.self, forKey: .isbn13)) ?? ""
        cover = (try? c.decode(String.self, forKey: .cover)) ?? ""
        publisher = (try? c.decode(String.self, forKey: .publisher)) ?? ""
        categoryName = (try? c.decode(String.self, forKey: .categoryName)) ?? ""
        categoryId = (try? c.decode(Int64.self, forKey: .categoryId)) ?? 0
    }
}
