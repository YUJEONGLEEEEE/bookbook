struct BookFilter {
    let name: String
    let categoryIds: [String]
}

let filters: [BookFilter] = [
    BookFilter(name: "전체", categoryIds: ["0"]),
    BookFilter(name: "아동", categoryIds: ["1108"]),
    BookFilter(name: "청소년", categoryIds: ["1137"]),
    BookFilter(name: "가정/생활", categoryIds: ["1230"]),
    BookFilter(name: "건강/취미", categoryIds: ["55890","1840","1196"]),
    BookFilter(name: "자기계발", categoryIds: ["336"]),
    BookFilter(name: "경제/경영", categoryIds: ["170"]),
    BookFilter(name: "역사", categoryIds: ["74"]),
    BookFilter(name: "종교", categoryIds: ["1237"]),
    BookFilter(name: "컴퓨터/IT", categoryIds: ["351"]),
    BookFilter(name: "만화/라이트노벨", categoryIds: ["2551","50927"]),
    BookFilter(name: "교육", categoryIds: ["50999","2030"]),
    BookFilter(name: "문학", categoryIds: ["2105","1","12011","31882"]),
    BookFilter(name: "에세이", categoryIds: ["55889"]),
    BookFilter(name: "예술", categoryIds: ["517"]),
    BookFilter(name: "사회과학", categoryIds: ["798"]),
    BookFilter(name: "과학/공학", categoryIds: ["987"]),
    BookFilter(name: "인문학", categoryIds: ["656"]),
    BookFilter(name: "전문서적", categoryIds: ["8257"])
]

