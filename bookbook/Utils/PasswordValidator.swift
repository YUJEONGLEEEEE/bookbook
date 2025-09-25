//
//  PasswordValidator.swift
//  bookbook
//
//  Created by 이유정 on 9/25/25.
//

import Foundation

enum PasswordValidationResult {
    case valid
    case invalid
}

struct PasswordValidator {
    static func validate(_ password: String) -> PasswordValidationResult {
        let lengthCondition = password.count >= 8 && password.count <= 20
        let upperClassCondition = password.range(of: "[A-Z]", options: .regularExpression) != nil
        let lowerClassCondition = password.range(of: "[a-z]", options: .regularExpression) != nil
        let specialCondition = password.range(of: "[!@#$%^&*(),.?\":{}|<>]", options: .regularExpression) != nil

        if lengthCondition && upperClassCondition && lowerClassCondition && specialCondition {
            return .valid
        }
        return .invalid
    }
}
