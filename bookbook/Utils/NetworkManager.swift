
import Foundation
import Alamofire

final class NetworkManager {
    static let shared = NetworkManager()
    private init() { }

    func searchBooks(query: String, category: Int, completion: @escaping (Result<BookInfo, AFError>) -> Void) {
        print(#function)

        let url = APIKey.baseURL
        let parameters: [String: Any] = [
            "TTBKey": APIKey.ttbKey,
            "Output": "JS",
            "Query": query,
            "QueryType": "Keyword",
            "SearchTarget": "Book",
            "MaxResults": 20,
            "Start": 1,
            "Sort": "Accuracy",
            "CategoryId": category,
            "outofStockfilter": 1
        ]

        AF.request(url,
                   method: .get,
                   parameters: parameters)
        .validate(statusCode: 200..<300)
        .responseDecodable(of: BookInfo.self) { response in
            switch response.result {
            case .success(let value):
                print(value)
                completion(.success(value))
            case .failure(let error):
                print(error)
                completion(.failure(error))
            }
        }
    }

    func bookLists(queryType: String, category: Int, completion: @escaping (Result<BookInfo, AFError>) -> Void) {
        print("listRequest: \(queryType)")

        let url = APIKey.baseURL
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
        .responseDecodable(of: BookInfo.self) { response in
            switch response.result {
            case .success(let value):
                print(value)
                completion(.success(value))
            case .failure(let error):
                print(error)
                completion(.failure(error))
            }
        }
    }

    func bookDetail(itemId: String, completion: @escaping (Result<BookInfo, AFError>) -> Void) {
        print("detailRequest: \(itemId)")

        let url = APIKey.baseURL
        let parameters: [String: Any] = [
            "TTBKey": APIKey.ttbKey,
            "Output": "JS",
            "ItemId": itemId,
        ]

        AF.request(url,
                   method: .get,
                   parameters: parameters)
        .validate(statusCode: 200..<300)
        .responseDecodable(of: BookInfo.self) { response in
            switch response.result {
            case .success(let value):
                print(value)
                completion(.success(value))
            case .failure(let error):
                print(error)
                completion(.failure(error))
            }
        }
    }
}
