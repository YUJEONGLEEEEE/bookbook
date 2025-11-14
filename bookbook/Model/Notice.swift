
import Foundation

struct Notice {
    let title: String
    let date: String
    let description: String
}

let noticeList: [Notice] = [
    Notice(title: "읽담 앱 오픈!", date: "2025.11.17", description: "안녕하세요./n책과 대화하는 앱, 읽담입니다./n/n읽담이 드디어 오픈하였습니다./n맞춤 책 추천을 비롯하여 책 검색 및 내책장에 담기, 책한줄 적기 등 다양한 서비스로 여러분을 찾아갈 예정입니다./n계속해서 발전하는 읽담이 되겠습니다./n많은 이용 부탁드립니다./n/n감사합니다."),
    Notice(title: "오류 수정", date: "2025.11.20", description: ""),
    Notice(title: "앱 업데이트 1.0.1", date: "2025.12.01", description: ""),
    Notice(title: "서비스 개선 안내", date: "2025.12.09", description: "")
]
