
import Foundation

enum NicknameValidationResult {
    case valid
    case invalidCount
    case invalidSpecialCharacter
    case invalidNumber
}

struct NicknameValidator {
    static func validate(_ nickname: String) -> NicknameValidationResult {
        if nickname.count < 2 || nickname.count > 8 {
            return .invalidCount
        }
        if nickname.contains(where: { "!@#$%^&*()-_+={}[]:;<>,." .contains($0) }) {
            return .invalidSpecialCharacter
        }
        if nickname.contains(where: { $0.isNumber}) {
            return .invalidNumber
        }
        return .valid
    }
}
