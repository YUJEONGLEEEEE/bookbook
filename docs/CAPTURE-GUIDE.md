# 읽담 포트폴리오 — 캡처 현황

## 완료 (30장)

`docs/screenshots/` 에 배치됨. 전부 **상태바를 잘라내고 가로 540px로 통일**함
(원본은 아이폰 실기기 1125×2436, 상단 132px 크롭 → 540×1106).

| 파일 | 화면 | | 파일 | 화면 |
|---|---|---|---|---|
| `01-onboarding-signup` | 회원가입 | | `17-home-ranking` | 마음 랭킹 |
| `02-onboarding-preference` | 취향(장르) | | `18-detail-liked` | 마음 표현 |
| `03-home` | 홈(명언 카드) | | `19-review-saved-push` | 푸시 알림 |
| `04-search` | 찾기 | | `20-loading` | 로딩 스피너 |
| `05-search-result` | 검색 결과 | | `21-notification-settings` | 알림 설정 |
| `06-detail` | 책 상세 | | `22-notification-inbox` | 알림함 |
| `07-shelf` | 내책장 | | `23-liked-drawer` | 마음서랍 |
| `08-review-list` | 책한줄 목록 | | `24-recent-books` | 최근 본 책 |
| `09-review-write` | 책한줄 작성 | | `25-my-preference` | 내 취향 |
| `10-tower-empty` | 책탑 빈 상태 | | `26-my-info` | 내 정보 |
| `11-tower` | 책탑 | | `27-notice-faq` | 공지 · FAQ |
| `12-reward-popup` | 보상 팝업 | | `28-qna-list` | 1:1 문의 |
| `14-mypage` | 내공간 | | `29-qna-form` | 문의하기 |
| `15-onboarding-age` | 취향(연령) | | `30-terms` | 이용약관 |
| `16-onboarding-gender` | 취향(성별) | | `31-app-version` | 앱 버전 |

## 남은 것

### 1. `13-reward-final.png` — 최종 보상(백과사전)

`BookReward.all`을 임시로 1단계(백과사전)만 남기도록 수정해 둠.
빌드 후 **내공간 → 책탑쌓기**에 들어가면 최종 보상 팝업이 바로 뜬다.

캡처가 끝나면 **반드시 원복**할 것:
```
cp <백업>/BookReward.swift.orig bookbook/Model/BookReward.swift
```

### 2. GIF 4개

`docs/gifs/` 에 아래 이름으로 넣는다.

| 파일명 | 장면 |
|---|---|
| `tower-reward.gif` | 책한줄 작성 → 책 떨어지는 애니메이션 → 보상 팝업 |
| `state-sync.gif` | 상세에서 마음 누름 → 뒤로가기 → 다른 화면에 즉시 반영 |
| `search-swipe-save.gif` | 검색 결과에서 스와이프 → 내책장 담기 |
| `loading.gif` | 로딩 스피너 |

변환에 ffmpeg 필요:
```
brew install ffmpeg
ffmpeg -i rec.mov -vf "fps=15,scale=320:-1:flags=lanczos" -loop 0 out.gif
```
5초 이내 · 가로 320px 권장.

### 3. `hero.png` (선택)

주요 화면 3~4개를 나란히 배치한 대표 이미지. README 최상단 주석을 해제하면 표시된다.

## 갱신 방법

이미지를 넣거나 바꾼 뒤:
```
./docs/build-pdf.sh
```
