
import Foundation

enum PhoneNumberValidationResult {
    case valid
    case invalidCount
    case invalidCharacter
}

struct PhoneNumberValidator {
    static func validate(_ phoneNumber: String) -> PhoneNumberValidationResult {
        if phoneNumber.count != 11 {
            return .invalidCount
        }
        if !phoneNumber.allSatisfy({ $0.isNumber }) {
            return .invalidCharacter
        }
        return .valid
    }
}
