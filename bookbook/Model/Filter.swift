//
//  Filter.swift
//  bookbook
//
//  Created by 이유정 on 9/16/25.
//

import Foundation

struct BookFilter {
    let name: String
    let query: String
}

let filters: [BookFilter] = [
    BookFilter(name: "전체", query: "all"),
    BookFilter(name: "문학", query: "문학"),
    BookFilter(name: "소설", query: "소설"),
    BookFilter(name: "에세이", query: "에세이"),
    BookFilter(name: "역사", query: "역사"),
    BookFilter(name: "과학", query: "과학"),
    BookFilter(name: "예술", query: "예술"),
    BookFilter(name: "교육", query: "교육"),
    BookFilter(name: "자기계발", query: "자기계발"),
    BookFilter(name: "경제/경영", query: "경제"),
    BookFilter(name: "인문학", query: "인문학"),
    BookFilter(name: "사회학", query: "사회"),
    BookFilter(name: "컴퓨터/IT", query: "컴퓨터"),
    BookFilter(name: "여행", query: "여행"),
    BookFilter(name: "아동/청소년", query: "아동"),
    BookFilter(name: "스포츠", query: "스포츠"),
    BookFilter(name: "만화/라이트노벨", query: "만화"),
    BookFilter(name: "종교", query: "종교")
]
