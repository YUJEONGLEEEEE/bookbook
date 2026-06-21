
import Foundation
import Alamofire

// 알라딘 Output=JS 응답은 끝에 ';'(+공백)가 붙어 유효 JSON이 아니므로 잘라낸다.
struct AladinJSPreprocessor: DataPreprocessor {
    func preprocess(_ data: Data) throws -> Data {
        var d = data
        let trim: Set<UInt8> = [0x3B, 0x20, 0x09, 0x0A, 0x0D] // ;  space  tab  \n  \r
        while let last = d.last, trim.contains(last) {
            d.removeLast()
        }
        return d
    }
}

final class NetworkManager {
    static let shared = NetworkManager()
    private init() { }

    func searchBooks(
        query: String,
        category: Int? = nil,
        sort: BookSortOption,
        page: Int = 1,
        completion: @escaping (Result<BookInfo, AFError>) -> Void
    ) {

        let url = APIKey.aladinSearchURL
        var parameters: [String: Any] = [
            "TTBKey": APIKey.ttbKey,
            "Output": "JS",
            "Query": query,
            "QueryType": "Keyword",
            "SearchTarget": "Book",
            "MaxResults": 20,
            "Start": (page - 1) * 20 + 1,
            "Sort": "Accuracy"
            // outofStockfilter 제거: 켜면 재고 도서만 반환돼 totalResults(전체 매칭)와 어긋나 뒤 페이지가 빔
        ]
        if let category {
            parameters["CategoryId"] = category
        }
        if let sortParm = sort.apiValue {
            parameters["Sort"] = sortParm
        }

        AF.request(url,
                   method: .get,
                   parameters: parameters)
        .validate(statusCode: 200..<300)
        .responseDecodable(of: BookInfo.self, dataPreprocessor: AladinJSPreprocessor()) { response in
            switch response.result {
            case .success(let value):
                // 제외 대상(참고서/교과서 수록도서 분야 + 세트 도서)을 걸러서 반환
                completion(.success(value.filteringExcluded()))
            case .failure(let error):
                debugLog(error)
                completion(.failure(error))
            }
        }
    }

    func bookLists(queryType: String, category: Int, completion: @escaping (Result<BookInfo, AFError>) -> Void) {

        let url = APIKey.aladinListURL
        let parameters: [String: Any] = [
            "TTBKey": APIKey.ttbKey,
            "Output": "JS",
            "QueryType": queryType,
            "SearchTarget": "Book",
            "CategoryId": category,
            "MaxResults": 20,
            "Start": 1,
            "outofStockfilter": 1,
            "Version": 20131101
        ]

        AF.request(url,
                   method: .get,
                   parameters: parameters)
        .validate(statusCode: 200..<300)
        .responseDecodable(of: BookInfo.self, dataPreprocessor: AladinJSPreprocessor()) { response in
            switch response.result {
            case .success(let value):
                // 제외 대상(참고서/교과서 수록도서 분야 + 세트 도서)을 걸러서 반환
                completion(.success(value.filteringExcluded()))
            case .failure(let error):
                debugLog(error)
                completion(.failure(error))
            }
        }
    }

    func bookDetail(isbn: Int, completion: @escaping (Result<naverBookInfo, AFError>) -> Void) {

        let url = APIKey.naverDetailURL
        let headers: HTTPHeaders = [
            "X-Naver-Client-Id": APIKey.naverCliendId,
            "X-Naver-Client-Secret": APIKey.naverClientSecret
        ]
        let parameter = [
            "d_isbn": isbn,
            "display": 1
        ]

        AF.request(url,
                   method: .get,
                   parameters: parameter,
                   headers: headers)
        .validate(statusCode: 200..<300)
        .responseDecodable(of: naverBookInfo.self) { response in
            switch response.result {
            case .success(let value):
                completion(.success(value))
            case .failure(let error):
                debugLog("네이버 검색 실패: \(isbn)")
                completion(.failure(error))
            }
        }
    }

    // 내책장: 북마크된 ISBN 목록을 알라딘 ItemLookUp으로 조회 (네이버 API엔 카테고리 정보 없음)
    func fetchBookmarkedBooks(isbns: [String], completion: @escaping ([BookData]) -> Void) {
        guard !isbns.isEmpty else {
            completion([])
            return
        }

        var booksByIsbn: [String: BookData] = [:]
        var failedISBNs: [String] = []
        let group = DispatchGroup()

        // 전체 북마크/마음 ISBN을 모두 조회 (페이지네이션이 전권을 페이징하도록)
        for isbnString in isbns {
            group.enter()
            fetchAladinBook(isbn13: isbnString) { book in
                defer { group.leave() }
                if let book {
                    booksByIsbn[isbnString] = book
                } else {
                    failedISBNs.append(isbnString)
                }
            }
        }

        group.notify(queue: .main) {
            // 사용자가 직접 담은 책이므로 제외(세트/전집 등) 없이 모두 표시. 입력 순서(최근 북마크 순) 유지.
            let ordered = isbns.compactMap { booksByIsbn[$0] }
            debugLog("📚 북마크 결과: 요청 \(isbns.count) / 조회성공 \(booksByIsbn.count) / 실패 \(failedISBNs.count) / 최종 \(ordered.count)")
            if !failedISBNs.isEmpty { debugLog("⚠️ 알라딘 조회 실패 ISBN: \(failedISBNs)") }
            completion(ordered)
        }
    }

    // 알라딘 ItemLookUp: ISBN13 한 권의 상세(카테고리 포함)를 조회한다.
    func fetchAladinBook(isbn13: String, completion: @escaping (BookData?) -> Void) {
        let url = "https://www.aladin.co.kr/ttb/api/ItemLookUp.aspx"
        let parameters: [String: Any] = [
            "TTBKey": APIKey.ttbKey,
            "Output": "JS",
            "ItemIdType": "ISBN13",
            "ItemId": isbn13,
            "Cover": "Big",
            "Version": 20131101
        ]

        AF.request(url,
                   method: .get,
                   parameters: parameters)
        .validate(statusCode: 200..<300)
        .responseDecodable(of: BookInfo.self, dataPreprocessor: AladinJSPreprocessor()) { response in
            switch response.result {
            case .success(let value):
                completion(value.item.first)
            case .failure(let error):
                debugLog("알라딘 ItemLookUp 실패(\(isbn13)): \(error)")
                completion(nil)
            }
        }
    }
}
