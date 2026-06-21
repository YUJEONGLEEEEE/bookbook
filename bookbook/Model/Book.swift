
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

    // 알라딘 에러 응답(totalResults·item 누락) 시 빈 결과로 처리
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

    // 로컬 전용 필드 (API 응답에 없음)
    var searchCategoryId: Int = 0
    var categoryId: Int64 = 0
    // 알라딘 카테고리 전체 경로 (예: "국내도서>자기계발>성공/처세")
    var categoryName: String = ""
    var likedCount: Int = 0
    var isBookmarked: Bool = false

    // API 응답에 존재하는 키만 디코딩
    enum CodingKeys: String, CodingKey {
        case title, author, pubDate, description, isbn13, cover, publisher, categoryName, categoryId
    }
}

extension BookData {
    // 제외할 분야 (CID 참고)
    // - 국내도서 > 고등학교참고서 (CID 76001)
    // - 국내도서 > 중학교참고서 (CID 76000)
    // - 국내도서 > 초등학교참고서 (CID 50246)
    // - 국내도서 > 어린이 > 교과서 수록도서 (CID 48806)
    // - 국내도서 > 만화 > 성인/성애만화 (CID 2562)
    // - 국내도서 > 달력/기타 (CID 4395)
    // - 국내도서 > 잡지 (CID 2913)
    // - 국내도서 > 수험서/자격증 (CID 1383)
    // - 국내도서 > 전집/중고전집 (CID 17195)
    static let excludedCategoryKeywords = [
        "고등학교참고서", "중학교참고서", "초등학교참고서", "교과서 수록도서",
        "성인/성애만화", "달력/기타", "잡지", "수험서/자격증", "전집/중고전집"
    ]

    // 카테고리 번호(CID)로 직접 제외하는 분야
    static let excludedCategoryIds: Set<Int64> = [181723, 181727]

    static let excludedTitleKeywords = ["세트", "전집"]
    // 세트 도서 제목 패턴 (예: 전 7권, 1~10권)
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
    // 필드 누락 시에도 안전하게 디코딩 (extension 정의로 멤버와이즈 init 유지)
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
