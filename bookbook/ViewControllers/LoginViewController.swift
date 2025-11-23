
import UIKit
import SnapKit

class LoginViewController: UIViewController {

    private var nicknameDelegate: AccountValidationDelegate!
    private var isNicknameValid = false
    private var isFloating = false

    private let backgroundImage: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.image = UIImage(named: "login_backgroundimage")
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .customFont(ofSize: 36, weight: .bold)
        label.text = "지금 로그인하고\n읽담을 시작하세요"
        label.textColor = .white
        label.textAlignment = .left
        label.numberOfLines = 2
        return label
    }()

    private let nicknameField: UITextField = {
        let field = UITextField()
        field.clearButtonMode = .whileEditing
        field.placeholder = "사용할 닉네임을 만들어주세요"
        field.textColor = .white
        field.textAlignment = .left
        field.keyboardType = .default
        field.font = .systemFont(ofSize: 17)
        field.backgroundColor = .clear
        return field
    }()

    private let nicknameUnderline: UIView = {
        let view = UIView()
        view.whiteUnderline()
        return view
    }()

    private let floatingLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = .systemFont(ofSize: 17)
        label.textAlignment = .left
        label.text = "닉네임"
        label.alpha = 0
        return label
    }()

    // nickname 유효성검사 -> 로그인버튼 색상변환
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 14)
        return label
    }()

    private let loginButton: UIButton = {
        let button = UIButton()
        button.confirmButton(title: "시작하기")
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white // imageview 넣고 빌드해보고 버퍼링 생기면 코드 유지 -> .clear 아니면 아예 코드 삭제하고 빌드하고 버퍼링 확인 필수
        configureUI()
        setupKeyboardDismissMode()
        addTargets()

        nicknameDelegate = AccountValidationDelegate(statusLabel: statusLabel, account: .nickname)
        nicknameDelegate.validationResultHandler = { [weak self] isValid in
            self?.isNicknameValid = isValid
            self?.activateLoginButton()
        }
        nicknameField.delegate = nicknameDelegate
    }

    private func addTargets() {
        nicknameField.addTarget(self, action: #selector(beginEditing), for: .editingDidBegin)
        nicknameField.addTarget(self, action: #selector(endEditing), for: .editingDidEnd)
        loginButton.addTarget(self, action: #selector(login), for: .touchUpInside)
    }
    @objc func beginEditing() {
        print(#function)
        guard !isFloating else { return }
        isFloating = true
        UIView.animate(withDuration: 0.3) {
            self.floatingLabel.alpha = 1
            self.floatingLabel.transform = CGAffineTransform(translationX: 0, y: -22).scaledBy(x: 0.85, y: 0.85)
        }
        nicknameField.placeholder = nil
    }
    @objc func endEditing() {
        print(#function)
        if nicknameField.text?.isEmpty ?? true {
            isFloating = false
            UIView.animate(withDuration: 0.2) {
                self.floatingLabel.alpha = 0
                self.floatingLabel.transform = .identity
            }
            nicknameField.placeholder = floatingLabel.text
        }
    }
    @objc func login() {
        print(#function)
        guard let nickname = nicknameField.text, !nickname.isEmpty, isNicknameValid else {
            return
        }
        CoreDataManager.shared.saveAccount(nickname: nickname)

        self.showToast("\(nickname)님 환영해요!")

        let preferVC = PreferenceCheckViewController()
        navigationController?.pushViewController(preferVC, animated: true)
    }

    private func activateLoginButton() {
        print(#function)

        if isNicknameValid {
            loginButton.backgroundColor = .customMain
            loginButton.isEnabled = true
        } else {
            loginButton.backgroundColor = .bk4
            loginButton.isEnabled = false
        }
    }

    private func configureUI() {
        view.addSubview(backgroundImage)
        backgroundImage.addSubviews([titleLabel, floatingLabel, nicknameField, nicknameUnderline, statusLabel, loginButton])
        backgroundImage.snp.makeConstraints { make in
            make.size.equalToSuperview()
        }
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(50)
        }
        floatingLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(18)
            make.bottom.equalTo(nicknameField.snp.top).offset(-4)
        }
        nicknameField.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(18)
            make.height.equalTo(44)
            make.top.equalTo(titleLabel.snp.bottom).offset(70)
        }
        nicknameUnderline.snp.makeConstraints { make in
            make.top.equalTo(nicknameField)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(16)
        }
        statusLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(22)
            make.top.equalTo(nicknameUnderline.snp.bottom).offset(10)
        }
        loginButton.snp.makeConstraints { make in
            make.horizontalEdges.bottom.equalTo(view.safeAreaLayoutGuide).inset(22)
            make.height.equalTo(44)
        }
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == nicknameField {
            textField.becomeFirstResponder()
        }
        return true
    }
}
