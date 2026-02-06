
import Foundation

final class GenreRecommendation {
    static func recommendedGenres(ageRange: AgeRange, gender: Gender) -> [String] {
        switch (ageRange, gender) {
        case (.child, _):
            return ["아동"]
        case (.teen, .female):
            return ["청소년", "자기계발", "만화/라이트노벨", "문학", "에세이"]
        case (.teen, .male):
            return ["청소년","건강/취미", "자기계발", "만화/라이트노벨", "과학/공학"]
        case (.adult, .female):
            return ["건강/취미", "자기계발", "문학", "에세이", "예술"]
        case (.adult, .male):
            return ["건강/취미", "자기계발", "경제/경영", "컴퓨터/IT", "과학/공학"]
        case (.senior, .female):
            return ["가정/생활", "건강/취미", "종교", "문학"]
        case (.senior, .male):
            return ["건강/취미", "경제/경영", "역사", "사회과학"]
        }
    }
}
