import UIKit

final class AccountValidationDelegate: NSObject, UITextFieldDelegate {

    private let statusLabel: UILabel

    enum Account {
        case nickname
        case phoneNumber
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
                statusLabel.text = "사용할 수 있는 이름이에요"
                statusLabel.textColor = .customGreen
                isValid = true
            case .invalidCount:
                statusLabel.text = "2글자 이상 8글자 이내로 작성해주세요"
                statusLabel.textColor = .customAlert
            case .invalidSpecialCharacter:
                statusLabel.text = "이름에 특수문자는 포함할 수 없어요"
                statusLabel.textColor = .customAlert
            case .invalidNumber:
                statusLabel.text = "이름에 숫자는 포함할 수 없어요"
                statusLabel.textColor = .customAlert
            }
        case .phoneNumber:
            if editedText.isEmpty {
                statusLabel.text = nil
                validationResultHandler?(false)
                return true
            }
            if !string.isEmpty && !string.allSatisfy({ $0.isNumber }) {
                statusLabel.text = "숫자만 입력해 주세요"
                statusLabel.textColor = .customAlert
                validationResultHandler?(false)
                return false
            }

            if editedText.count > 11 {
                validationResultHandler?(false)
                return false
            }

            let result = PhoneNumberValidator.validate(editedText)
            switch result {
            case .valid:
                statusLabel.text = "사용할 수 있는 휴대폰 번호에요"
                statusLabel.textColor = .customGreen
                isValid = true
            case .invalidCount:
                statusLabel.text = "휴대폰 번호는 11자리로 입력해 주세요"
                statusLabel.textColor = .customAlert
            case .invalidCharacter:
                statusLabel.text = "숫자만 입력해 주세요"
                statusLabel.textColor = .customAlert
            }
        }
        validationResultHandler?(isValid)
        return true
    }
}
