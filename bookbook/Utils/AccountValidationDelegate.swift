//
//  AccountValidationDelegate.swift
//  bookbook
//
//  Created by 이유정 on 9/25/25.
//

import UIKit

class AccountValidationDelegate: NSObject, UITextFieldDelegate {
    private let statusLabel: UILabel
    enum Account {
        case nickname
//        case password
    }
    private let account: Account

    var validationResultHandler: ((Bool) -> Void)?

    init(statusLabel: UILabel, account: Account) {
        self.statusLabel = statusLabel
        self.account = account
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let currentText = textField.text,
              let range = Range(range, in: currentText) else { return false }
        let editedText = currentText.replacingCharacters(in: range, with: string)

        var isValid = false

        switch account {
        case .nickname:
            let result = NicknameValidator.validate(editedText)
            switch result {
            case .valid:
                statusLabel.text = "사용할 수 있는 닉네임이에요"
                statusLabel.textColor = .systemBlue
                isValid = true
            case .invalidCount:
                statusLabel.text = "2글자 이상 10글자 미만으로 설정해주세요"
                statusLabel.textColor = .lightGray
            case .invalieSpecialCharacter:
                statusLabel.text = "닉네임에 @, #, $, %, & 는 포함할 수 없어요"
                statusLabel.textColor = .lightGray
            case .invalidNumber:
                statusLabel.text = "닉네임에 숫자는 포함할 수 없어요"
                statusLabel.textColor = .lightGray
            }

//        case .password:
//            let result = PasswordValidator.validate(editedText)
//            switch result {
//            case .valid:
//                statusLabel.text = ""
//                isValid = true
//            case .invalid:
//                statusLabel.text = "대문자, 소문자, 숫자를 포함한 8글자 이상 20글자 이하로 설정해주세요"
//                statusLabel.textColor = .lightGray
//            }
        }

        validationResultHandler?(isValid)

        return true
    }
}
