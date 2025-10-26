
import Foundation

struct BookFilter {
    let name: String
    let categoryId: String
}

let filters: [BookFilter] = [
    BookFilter(name: "전체", categoryId: "0"),
    BookFilter(name: "아동", categoryId: "1108"),
    BookFilter(name: "청소년", categoryId: "1137"),
    BookFilter(name: "가정/생활", categoryId: "1230"),
    BookFilter(name: "건강/취미", categoryId: "55890"),
    BookFilter(name: "건강/취미", categoryId: "1840"),
    BookFilter(name: "건강/취미", categoryId: "1196"),
    BookFilter(name: "자기계발", categoryId: "336"),
    BookFilter(name: "경제/경영", categoryId: "170"),
    BookFilter(name: "역사", categoryId: "74"),
    BookFilter(name: "종교", categoryId: "1237"),
    BookFilter(name: "컴퓨터/IT", categoryId: "351"),
    BookFilter(name: "만화/라이트노벨", categoryId: "2551"),
    BookFilter(name: "만화/라이트노벨", categoryId: "50927"),
    BookFilter(name: "교육", categoryId: "50999"),
    BookFilter(name: "교육", categoryId: "2030"),
    BookFilter(name: "문학", categoryId: "2105"),
    BookFilter(name: "문학", categoryId: "1"),
    BookFilter(name: "문학", categoryId: "12011"),
    BookFilter(name: "문학", categoryId: "31882"),
    BookFilter(name: "에세이", categoryId: "55889"),
    BookFilter(name: "예술", categoryId: "517"),
    BookFilter(name: "사회과학", categoryId: "798"),
    BookFilter(name: "과학/공학", categoryId: "987"),
    BookFilter(name: "인문학", categoryId: "656"),
    BookFilter(name: "전문서적", categoryId: "8257")
]
