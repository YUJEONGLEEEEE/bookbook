import Foundation

struct BookReward {

    let count: Int        // 이 보상을 받기 위한 책한줄 작성 횟수
    let name: String
    let imageName: String // 표지 에셋 이름 (EventImages)

    // 기획서 기준 9단계 보상
    static let all: [BookReward] = [
        BookReward(count: 3,  name: "전래동화",   imageName: "book_fairytale"),
        BookReward(count: 5,  name: "이솝우화",   imageName: "book_aesop"),
        BookReward(count: 10, name: "영어책",     imageName: "book_english"),
        BookReward(count: 15, name: "자서전",     imageName: "book_autobiography"),
        BookReward(count: 20, name: "추리소설",   imageName: "book_mystery"),
        BookReward(count: 25, name: "세계지도",   imageName: "book_worldmap"),
        BookReward(count: 30, name: "요리책",     imageName: "book_cook"),
        BookReward(count: 35, name: "우주과학",   imageName: "book_science"),
        BookReward(count: 40, name: "백과사전",   imageName: "book_encyclopedia"),
    ]

    // 각 보상까지의 누적 필요 횟수
    static func cumulativeThresholds() -> [Int] {
        var sum = 0
        return all.map { sum += $0.count; return sum }
    }

    static func earned(for writtenCount: Int) -> [BookReward] {
        zip(all, cumulativeThresholds()).filter { $0.1 <= writtenCount }.map { $0.0 }
    }

    // 다음으로 받을 보상(없으면 nil = 최고 단계 달성)
    static func next(after writtenCount: Int) -> BookReward? {
        for (reward, threshold) in zip(all, cumulativeThresholds()) where threshold > writtenCount {
            return reward
        }
        return nil
    }
}

enum LevelRewardStore {
    // 계정별로 분리 (다른 계정의 보상 연출 상태를 이어받지 않도록)
    private static var key: String { UserSession.scopedKey("acknowledgedRewardCounts") }

    static func acknowledged() -> Set<Int> {
        Set(UserDefaults.standard.array(forKey: key) as? [Int] ?? [])
    }

    static func markAcknowledged(_ counts: [Int]) {
        var set = acknowledged()
        counts.forEach { set.insert($0) }
        UserDefaults.standard.set(Array(set), forKey: key)
    }

    // 현재 획득 상태인 보상만 남기고 제거 (기록 삭제로 미획득이 된 책은 해제 → 재획득 시 연출 재생)
    static func retain(_ counts: Set<Int>) {
        UserDefaults.standard.set(Array(acknowledged().intersection(counts)), forKey: key)
    }

    // 회원탈퇴 시 전체 초기화
    static func clear() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
