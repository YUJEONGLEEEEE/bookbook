
import Foundation

struct Notice {
    let title: String
    let date: String
    let description: String
}

let noticeList: [Notice] = [
    Notice(title: "서비스 개선 안내", date: "2025.11.26", description: "안녕하세요.\n책과 대화하는 앱, 읽담입니다.\n\n더 나은 사용 경험을 위해 일부 화면과 기능을 개선했어요.\n앞으로도 읽담을 더 편리하게 사용하실 수 있도록 꾸준히 노력하겠습니다.\n\n감사합니다."),
    Notice(title: "앱 업데이트 1.0.1", date: "2025.11.15", description: "안녕하세요.\n책과 대화하는 앱, 읽담입니다.\n\n1.0.1 버전이 업데이트되었습니다.\n- 일부 화면 레이아웃 개선\n- 사용성 향상\n\n원활한 이용을 위해 최신 버전으로 업데이트해 주세요.\n\n감사합니다."),
    Notice(title: "오류 수정", date: "2025.11.08", description: "안녕하세요.\n책과 대화하는 앱, 읽담입니다.\n\n제보해 주신 일부 오류를 수정했어요.\n불편을 드려 죄송하며, 더 안정적인 서비스로 보답하겠습니다.\n\n감사합니다."),
    Notice(title: "읽담 앱 오픈!", date: "2025.10.30", description: "안녕하세요.\n책과 대화하는 앱, 읽담입니다.\n\n오랫동안 준비해온 읽담이 드디어 여러분 곁에 첫 발을 내딛습니다.\n\n책을 찾고, 담고, 마음에 남은 문장을 기록하는 순간들이 오롯이 여러분만의 이야기로 쌓여가길 바라는 마음으로 만들었습니다.\n\n따뜻한 관심과 많은 이용 부탁드립니다.\n\n감사합니다.")
]
