import Foundation

struct BookReward {

    let count: Int
    let name: String
    let imageName: String

    var isFinal: Bool { count == BookReward.all.last?.count }

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

    static func cumulativeThresholds() -> [Int] {
        var sum = 0
        return all.map { sum += $0.count; return sum }
    }

    static func earned(for writtenCount: Int) -> [BookReward] {
        zip(all, cumulativeThresholds()).filter { $0.1 <= writtenCount }.map { $0.0 }
    }

    static func next(after writtenCount: Int) -> BookReward? {
        for (reward, threshold) in zip(all, cumulativeThresholds()) where threshold > writtenCount {
            return reward
        }
        return nil
    }
}

enum LevelRewardStore {
    private static var key: String { UserSession.scopedKey("acknowledgedRewardCounts") }

    static func acknowledged() -> Set<Int> {
        Set(UserDefaults.standard.array(forKey: key) as? [Int] ?? [])
    }

    static func markAcknowledged(_ counts: [Int]) {
        var set = acknowledged()
        counts.forEach { set.insert($0) }
        UserDefaults.standard.set(Array(set), forKey: key)
    }

    static func retain(_ counts: Set<Int>) {
        UserDefaults.standard.set(Array(acknowledged().intersection(counts)), forKey: key)
    }

    static func clear() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
