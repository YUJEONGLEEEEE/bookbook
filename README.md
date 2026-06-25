# 읽담 (bookbook)

> 책과 대화하는 독서 기록 앱 — 검색하고, 담고, 한 줄로 기록하고, 책탑을 쌓음.

읽담은 책을 검색해 내 책장에 담고, **책한줄** 리뷰를 남기면 책을 모아 **책탑**을 쌓아가는 iOS 독서 기록 앱임.

## 탭 구성

| <img src="bookbook/Assets.xcassets/TabBarItem/home_on.imageset/home_on@2x.png" width="36"> | <img src="bookbook/Assets.xcassets/TabBarItem/search_on.imageset/search_on@2x.png" width="36"> | <img src="bookbook/Assets.xcassets/TabBarItem/bookshelf_on.imageset/bookshelf_on@2x.png" width="36"> | <img src="bookbook/Assets.xcassets/TabBarItem/comments_on.imageset/comments_on@2x.png" width="36"> | <img src="bookbook/Assets.xcassets/TabBarItem/mypage_on.imageset/mypage_on@2x.png" width="36"> |
|:---:|:---:|:---:|:---:|:---:|
| 홈 | 찾기 | 내책장 | 책한줄 | 내공간 |

## 주요 기능

### <img src="bookbook/Assets.xcassets/MainIcons/menu_myinfo.imageset/menu_myinfo@2x.png" width="20"> 온보딩 · 인증
- 휴대폰 번호 기반 회원가입 / 로그인
- 취향 설정(선호 장르 · 연령대 · 성별) → 맞춤 추천에 활용
- 첫 진입 튜토리얼

### <img src="bookbook/Assets.xcassets/TabBarItem/home_on.imageset/home_on@2x.png" width="20"> 홈
- **맞춤 추천**: 취향 · 연령 · 성별 기반 추천 도서
- **마음 랭킹**: 이번 주 많은 '마음'을 받은 책
- **베스트셀러 · 신간** (알라딘 기준)
- 명언 카드 · 당겨서 새로고침

### <img src="bookbook/Assets.xcassets/TabBarItem/search_on.imageset/search_on@2x.png" width="20"> 찾기 (검색)
- 알라딘 도서 검색 / 정렬(정확도 · 추천(판매량) · 최신) / 장르 필터 / 페이지네이션
- 최근 검색어 · 인기 검색어
- 스와이프로 바로 내책장 담기

### 책 상세
- 네이버 도서 상세 정보
- 마음(좋아요) · 내책장 담기 · 책한줄 작성

### <img src="bookbook/Assets.xcassets/TabBarItem/bookshelf_on.imageset/bookshelf_on@2x.png" width="20"> 내책장 · 마음서랍
- 북마크한 책 / 좋아요한 책 모음 (장르 필터 · 페이지네이션)

### <img src="bookbook/Assets.xcassets/TabBarItem/comments_on.imageset/comments_on@2x.png" width="20"> 책한줄 (리뷰)
- 한 줄 리뷰 작성 / 수정 / 삭제, 별점 · 읽은 날짜 기록

### <img src="bookbook/Assets.xcassets/StandardIcons/booktower.imageset/booktower@2x.png" width="20"> 책탑쌓기 (게이미피케이션)
- 책한줄을 모으면 단계별로 책 획득 (전래동화 → … → 백과사전, **총 9단계**)
- 책이 떨어지는 GIF 애니메이션 + 진행 게이지 + 보상 팝업
- 내공간 상단 프로필 카드와 실시간 동기화

### 알림
- 시스템 로컬 푸시(새 책 획득 · 독서 리마인더) + 앱 내 알림함(안읽음 배지)
- 독서 리마인더: **반복 요일 · 시간 · 하루 횟수** 설정

### <img src="bookbook/Assets.xcassets/TabBarItem/mypage_on.imageset/mypage_on@2x.png" width="20"> 내공간 (마이페이지)
- 프로필 카드(획득 책 · 다짐 한마디)
- 내 정보 · 내 취향 · 최근 본 책 · 공지/FAQ · 1:1 문의 · 이용약관 · 앱 버전

## 기술 스택

| 구분 | 사용 기술 |
|---|---|
| 언어 / 패턴 | Swift · UIKit · MVC |
| 레이아웃 | SnapKit (코드 기반 오토레이아웃) |
| 네트워크 | Alamofire |
| 이미지 | Kingfisher (GIF: AnimatedImageView) |
| 로컬 저장 | CoreData |
| 알림 | UserNotifications (로컬 푸시) |
| 오픈 API | 알라딘 도서 API · 네이버 책 API |

## 아키텍처 · 특징

- **MVC 패턴** + 코드 기반 UI(SnapKit)
- **상태 동기화**: 북마크 · 마음 상태를 `NotificationCenter`로 전 화면 실시간 반영
- **CoreData 로컬 영속화**: `Account` · `Book` · `Bookmark` · `Comment` · `Liked`
- **디자인 시스템**: Figma 시안 1:1 매칭, 네임드 컬러 + 커스텀 폰트(AppleSDGothicNeo), 커스텀 얼럿 · 토스트
- **API 예외 처리**: 알라딘 JS 응답 전처리, 참고서 · 교과서 · 세트 · e-book 등 불필요 도서 필터링

## 인증 및 데이터 저장 방식

포트폴리오용 데모로, 별도의 백엔드 서버 없이 **CoreData 기반 로컬 전용**으로 구현함.

- 회원가입 · 로그인은 기기 내 로컬 계정으로 동작하며, 입력한 휴대폰 번호는 형식 검증만 수행함 (SMS 인증 · 비밀번호 없음).
- 모든 데이터는 기기의 CoreData에 저장되어, 앱 삭제 또는 기기 변경 시 초기화됨.

> **실 서비스로 확장 시 필요한 작업**
> - 휴대폰 번호 SMS(OTP) 인증
> - 서버/클라우드 DB + 동기화(CloudKit · Firebase 등)를 통한 기기 간 데이터 이전

이는 데모 범위를 명확히 하기 위한 **의도적인 설계 선택임**.

## 실행 방법

1. 저장소 클론 후 Xcode에서 `bookbook.xcodeproj` 열기 (iOS 17+)
2. `bookbook/Secret.swift.example`을 같은 폴더에 복사 → `Secret.swift`로 이름 변경 후 API 키 입력 (알라딘 TTB Key, 네이버 Client ID/Secret)
   - `Secret.swift`는 `.gitignore`로 제외돼 GitHub에 올라가지 않음(받은 프로젝트엔 없으니 직접 생성 필요).
   - 실제 키 값은 프로젝트 관리자에게 요청.
3. 빌드 & 실행

---

# bookbook (English)

> A reading-record app for conversing with books — search, save, jot a one-line review, and build a book tower.

bookbook is an iOS reading-record app: search for books, save them to your shelf, leave **one-line reviews (책한줄)**, and collect books to build a **book tower (책탑)**.

## Tabs

| <img src="bookbook/Assets.xcassets/TabBarItem/home_on.imageset/home_on@2x.png" width="36"> | <img src="bookbook/Assets.xcassets/TabBarItem/search_on.imageset/search_on@2x.png" width="36"> | <img src="bookbook/Assets.xcassets/TabBarItem/bookshelf_on.imageset/bookshelf_on@2x.png" width="36"> | <img src="bookbook/Assets.xcassets/TabBarItem/comments_on.imageset/comments_on@2x.png" width="36"> | <img src="bookbook/Assets.xcassets/TabBarItem/mypage_on.imageset/mypage_on@2x.png" width="36"> |
|:---:|:---:|:---:|:---:|:---:|
| Home | Search | Shelf | Review | My Space |

## Features

### <img src="bookbook/Assets.xcassets/MainIcons/menu_myinfo.imageset/menu_myinfo@2x.png" width="20"> Onboarding & Auth
- Phone-number-based sign-up / sign-in
- Preference setup (genre · age group · gender) used for recommendations
- First-launch tutorial

### <img src="bookbook/Assets.xcassets/TabBarItem/home_on.imageset/home_on@2x.png" width="20"> Home
- **Personalized recommendations** based on preference · age · gender
- **Likes ranking**: books that received the most "마음" (likes) this week
- **Bestsellers · New releases** (via Aladin)
- Quote card · pull-to-refresh

### <img src="bookbook/Assets.xcassets/TabBarItem/search_on.imageset/search_on@2x.png" width="20"> Search
- Aladin book search / sort (accuracy · recommended (sales) · newest) / genre filter / pagination
- Recent & popular search terms
- Swipe to add to the shelf instantly

### Book Detail
- Naver book detail info
- Like · add to shelf · write a one-line review

### <img src="bookbook/Assets.xcassets/TabBarItem/bookshelf_on.imageset/bookshelf_on@2x.png" width="20"> My Shelf · Likes Drawer
- Bookmarked / liked books (genre filter · pagination)

### <img src="bookbook/Assets.xcassets/TabBarItem/comments_on.imageset/comments_on@2x.png" width="20"> One-line Review (책한줄)
- Create / edit / delete a one-line review, with rating & read date

### <img src="bookbook/Assets.xcassets/StandardIcons/booktower.imageset/booktower@2x.png" width="20"> Book Tower (gamification)
- Collect one-line reviews to earn books step by step (전래동화 → … → 백과사전, **9 levels**)
- Falling-book GIF animation + progress gauge + reward popup
- Synced in real time with the profile card in My Space

### Notifications
- System local push (new book earned · reading reminder) + in-app inbox (unread badge)
- Reading reminder: configurable **repeat days · times · count per day**

### <img src="bookbook/Assets.xcassets/TabBarItem/mypage_on.imageset/mypage_on@2x.png" width="20"> My Space (My Page)
- Profile card (earned book · personal motto)
- My Info · My Preferences · Recently viewed books · Notices/FAQ · 1:1 Inquiry · Terms · App version

## Tech Stack

| Category | Technology |
|---|---|
| Language / Pattern | Swift · UIKit · MVC |
| Layout | SnapKit (programmatic Auto Layout) |
| Networking | Alamofire |
| Images | Kingfisher (GIF: AnimatedImageView) |
| Local storage | CoreData |
| Notifications | UserNotifications (local push) |
| Open APIs | Aladin Book API · Naver Book API |

## Architecture & Highlights

- **MVC pattern** with fully programmatic UI (SnapKit)
- **State sync**: bookmark · like state reflected across all screens in real time via `NotificationCenter`
- **CoreData local persistence**: `Account` · `Book` · `Bookmark` · `Comment` · `Liked`
- **Design system**: 1:1 match with Figma, named asset colors + custom font (AppleSDGothicNeo), custom alerts · toasts
- **API handling**: Aladin JS-response preprocessing; filters out reference books, textbooks, box sets, e-books, etc.

## Authentication & Data Storage

Built as a portfolio demo — **local-only, backed by CoreData with no backend server**.

- Sign-up / sign-in run as on-device local accounts; the entered phone number is only format-validated (no SMS verification or password).
- All data is stored in the device's CoreData, so it is reset when the app is deleted or the device changes.

> **What a production service would additionally need**
> - Phone-number SMS (OTP) verification
> - A server/cloud database with sync (CloudKit · Firebase, etc.) for cross-device data transfer

This is an intentional design choice to keep the demo scope clear.

## Getting Started

1. Clone the repo and open `bookbook.xcodeproj` in Xcode (iOS 17+)
2. Copy `bookbook/Secret.swift.example` to `Secret.swift` in the same folder, then fill in the API keys (Aladin TTB Key, Naver Client ID/Secret)
   - `Secret.swift` is excluded via `.gitignore`, so it is not on GitHub — you must create it yourself.
   - Ask the project owner for the actual key values.
3. Build & run

---

## 커밋 컨벤션 / Commit Convention

| Type | Description | Example |
|------|-------------|---------|
| feat | New feature | feat: add book search feature |
| fix | Bug fix | fix: resolve login error |
| docs | Documentation | docs: add README |
| style | Formatting (no logic) | style: fix indentation |
| refactor | Code refactoring | refactor: simplify reward logic |
| test | Test code | test: add login tests |
| chore | Build/config | chore: update dependencies |
| ui | UI addition/change | ui: update main layout |
