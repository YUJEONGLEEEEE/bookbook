//
//  NetworkManager.swift
//  bookbook
//
//  Created by 이유정 on 9/16/25.
//

import Foundation
import Alamofire

final class NetworkManager {
    static let shared = NetworkManager()
    private init() { }

    func searchBooks(query: String, completion: @escaping (Result<BookInfo, AFError>) -> Void) {
        print(#function)

        let url = APIKey.baseURL
        let headers: HTTPHeaders = [
            "X-Naver-Client-Id": APIKey.naverClientId,
            "X-Naver-Client-Secret": APIKey.naverClientSecret
        ]
        let parameters: [String: Any] = [
            "query": query,
            "display": 100,
            "start": 1
        ]

        AF.request(url,
                   method: .get,
                   parameters: parameters,
                   headers: headers)
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
