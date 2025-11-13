import UIKit

class AccountValidationDelegate: NSObject, UITextFieldDelegate {
    private let statusLabel: UILabel
    enum Account {
        case nickname
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
                statusLabel.text = "2글자 이상 8글자 이내로 작성해주세요"
                statusLabel.textColor = .customAlert
            case .invalieSpecialCharacter:
                statusLabel.text = "닉네임에 특수문자는 포함할 수 없어요"
                statusLabel.textColor = .customAlert
            case .invalidNumber:
                statusLabel.text = "닉네임에 숫자는 포함할 수 없어요"
                statusLabel.textColor = .customAlert
            }
        }
        validationResultHandler?(isValid)
        return true
    }
}
