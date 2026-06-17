struct BookFilter {
    let name: String
    let categoryIds: [String]      // 알라딘 카테고리 검색용 (찾기/홈 화면)
    let keywords: [String]         // 내책장 장르 필터용 (알라딘 categoryName 경로 매칭)

    /// 알라딘 카테고리 경로(categoryName)가 이 필터에 해당하는지 판단한다.
    /// keywords 가 비어 있으면(전체) 항상 true.
    func matches(categoryName: String) -> Bool {
        guard !keywords.isEmpty else { return true }
        return keywords.contains { categoryName.contains($0) }
    }
}

let filters: [BookFilter] = [
    BookFilter(name: "전체", categoryIds: ["0"], keywords: []),
    BookFilter(name: "아동", categoryIds: ["1108"], keywords: ["어린이", "유아", "아동"]),
    BookFilter(name: "청소년", categoryIds: ["1137"], keywords: ["청소년"]),
    BookFilter(name: "가정/생활", categoryIds: ["1230"], keywords: ["가정", "요리", "뷰티", "살림", "임신", "출산", "육아", "좋은부모"]),
    BookFilter(name: "건강/취미", categoryIds: ["55890","1840","1196"], keywords: ["건강", "취미", "레저", "스포츠", "원예", "반려"]),
    BookFilter(name: "자기계발", categoryIds: ["336"], keywords: ["자기계발"]),
    BookFilter(name: "경제/경영", categoryIds: ["170"], keywords: ["경제경영", "경제/경영", "경영", "재테크"]),
    BookFilter(name: "역사", categoryIds: ["74"], keywords: ["역사"]),
    BookFilter(name: "종교", categoryIds: ["1237"], keywords: ["종교", "역학"]),
    BookFilter(name: "컴퓨터/IT", categoryIds: ["351"], keywords: ["컴퓨터", "모바일", "프로그래밍", "IT"]),
    BookFilter(name: "만화/라이트노벨", categoryIds: ["2551","50927"], keywords: ["만화", "라이트노벨"]),
    BookFilter(name: "교육", categoryIds: ["50999","2030"], keywords: ["대학교재", "수험서", "자격증", "참고서", "외국어", "교재", "교육"]),
    BookFilter(name: "문학", categoryIds: ["2105","1","12011","31882"], keywords: ["소설", "시/희곡", "희곡", "문학", "장르소설"]),
    BookFilter(name: "에세이", categoryIds: ["55889"], keywords: ["에세이"]),
    BookFilter(name: "예술", categoryIds: ["517"], keywords: ["예술", "대중문화", "음악", "미술"]),
    BookFilter(name: "사회과학", categoryIds: ["798"], keywords: ["사회과학", "정치", "사회"]),
    BookFilter(name: "과학/공학", categoryIds: ["987"], keywords: ["과학", "공학", "기술"]),
    BookFilter(name: "인문학", categoryIds: ["656"], keywords: ["인문", "철학", "심리"]),
    BookFilter(name: "전문서적", categoryIds: ["8257"], keywords: ["전문서적", "의학", "법", "간호"])
]
