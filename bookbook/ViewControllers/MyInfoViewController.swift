
import UIKit
import SnapKit

class MyInfoViewController: UIViewController {

    private let nicknameStack: UIStackView = {
        let view = UIStackView()
        return view
    }()

    private let nicknameLabel: UILabel = {
        let label = UILabel()
        label.text = "닉네임"
        return label
    }()

    private let userNickname: UITextField = {
        let field = UITextField()
//        field.text = "\(nickname)"
        return field
    }()

    private let nicknameUnderline: UIView = {
        let view = UIView()
        view.addUnderline()
        return view
    }()

    private let birthdayStack: UIStackView = {
        let view = UIStackView()
        return view
    }()

    private let birthdayLabel: UILabel = {
        let label = UILabel()
        label.text = "생년월일"
        return label
    }()

    private let userBirthday: UITextField = {
        let field = UITextField()
        return field
    }()

    private let birthdayUnderline: UIView = {
        let view = UIView()
        view.addUnderline()
        return view
    }()

    private let emailStack: UIStackView = {
        let view = UIStackView()
        return view
    }()

    private let emailLabel: UILabel = {
        let label = UILabel()
        label.text = "이메일"
        return label
    }()

    private let userEmail: UITextField = {
        let field = UITextField()
        return field
    }()

    private let emailUnderline: UIView = {
        let view = UIView()
        return view
    }()

    private let phoneStack: UIStackView = {
        let view = UIStackView()
        return view
    }()

    private let phoneLabel: UILabel = {
        let label = UILabel()
        label.text = "휴대폰 번호"
        return label
    }()

    private let userPhone: UITextField = {
        let field = UITextField()
        return field
    }()

    private let phoneUnderline: UIView = {
        let view = UIView()
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureUI()
    }

    private func configureUI() {
        view.addSubviews([nicknameStack, birthdayStack, emailStack, phoneStack])
        nicknameStack.addArrangedSubviews([nicknameLabel, userNickname, nicknameUnderline])
        birthdayStack.addArrangedSubviews([birthdayLabel, userBirthday, birthdayUnderline])
        emailStack.addArrangedSubviews([emailLabel, userEmail, emailUnderline])
        phoneStack.addArrangedSubviews( [phoneLabel, userPhone, phoneUnderline])
    }
}
