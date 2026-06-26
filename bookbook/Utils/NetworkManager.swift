
import Foundation
import Alamofire

struct AladinJSPreprocessor: DataPreprocessor {
    func preprocess(_ data: Data) throws -> Data {
        var d = data
        let trim: Set<UInt8> = [0x3B, 0x20, 0x09, 0x0A, 0x0D]
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

    func fetchBookmarkedBooks(isbns: [String], completion: @escaping ([BookData]) -> Void) {
        guard !isbns.isEmpty else {
            completion([])
            return
        }

        var booksByIsbn: [String: BookData] = [:]
        var failedISBNs: [String] = []
        let group = DispatchGroup()

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
            let ordered = isbns.compactMap { booksByIsbn[$0] }
            debugLog("📚 북마크 결과: 요청 \(isbns.count) / 조회성공 \(booksByIsbn.count) / 실패 \(failedISBNs.count) / 최종 \(ordered.count)")
            if !failedISBNs.isEmpty { debugLog("⚠️ 알라딘 조회 실패 ISBN: \(failedISBNs)") }
            completion(ordered)
        }
    }

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
