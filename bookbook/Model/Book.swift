//
//  Book.swift
//  bookbook
//
//  Created by 이유정 on 9/16/25.
//

import Foundation

struct BookInfo: Decodable {
    let items: [BookData]
}

struct BookData: Decodable {
    let title: String
    let link: String
    let image: String
    let author: String
    let discount: Int?
    let publisher: String
    let pubdate: Int
    let isbn: Int
    let description: String
}
