//
//  LoginViewController.swift
//  bookbook
//
//  Created by 이유정 on 9/24/25.
//

import UIKit
import SnapKit

class LoginViewController: UIViewController {

    private var nicknameDelegate: AccountValidationDelegate!
//    private var passwordDelegate: AccountValidationDelegate!
    private var isNicknameValid = false
//    private var isPasswordValid = false
    private var isFloating = false

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "지금 로그인하고\n북북을 시작하세요"
        label.textColor = .black
        label.textAlignment = .left
        label.numberOfLines = 2
        label.font = .boldSystemFont(ofSize: 34)
        return label
    }()

//    private let loginStackView: UIStackView = {
//        let view = UIStackView()
//        return view
//    }()

    private let nicknameField: UITextField = {
        let field = UITextField()
        field.clearButtonMode = .whileEditing
        field.placeholder = "사용할 닉네임을 만들어주세요"
        field.textColor = .black
        field.textAlignment = .left
        field.keyboardType = .default
        field.font = .systemFont(ofSize: 17)
        field.backgroundColor = .clear
        return field
    }()

    private let nicknameUnderline: UIView = {
        let view = UIView()
        view.addUnderline()
        return view
    }()

    private let floatingLabel: UILabel = {
        let label = UILabel()
        label.standardLabel()
        label.alpha = 0
        return label
    }()

//    private let passwordField: UITextField = {
//        let field = UITextField()
//        field.textContentType = .password
//        field.clearButtonMode = .whileEditing
//        field.placeholder = "비밀번호를 입력해주세요"
//        field.textColor = .black
//        field.textAlignment = .left
//        field.keyboardType = .default
//        field.font = .systemFont(ofSize: 17)
//        field.backgroundColor = .clear
//        field.isSecureTextEntry = true
//        return field
//    }()

//    private let passwordUnderline: UIView = {
//        let view = UIView()
//        view.addUnderline()
//        return view
//    }()

    // password 유효성검사 -> 로그인버튼 색상변환
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = .lightGray
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 14)
        return label
    }()

    private let loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("시작하기", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.font = .boldSystemFont(ofSize: 17)
        button.backgroundColor = .lightGray
        button.isEnabled = false
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        return button
    }()

//    private let signUpButton: UIButton = {
//        let button = UIButton()
//        return button
//    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureUI()
        floatingLabel.text = nicknameField.placeholder
        setupKeyboardDismissMode()
        addTargets()

        nicknameDelegate = AccountValidationDelegate(statusLabel: statusLabel, account: .nickname)
        nicknameDelegate.validationResultHandler = { [weak self] isValid in
            self?.isNicknameValid = isValid
            self?.activateLoginButton()
        }
        nicknameField.delegate = nicknameDelegate

//        passwordDelegate = AccountValidationDelegate(statusLabel: statusLabel, account: .password)
//        passwordDelegate.validationResultHandler = { [weak self] isValid in
//            self?.isPasswordValid = isValid
//            self?.activateLoginButton()
//        }
//        passwordField.delegate = passwordDelegate
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
        let preferVC = PreferenceCheckViewController()
        navigationController?.pushViewController(preferVC, animated: true)
    }

    private func activateLoginButton() {
        print(#function)
//        if isNicknameValid && isPasswordValid {
//            loginButton.backgroundColor = .systemBlue
//            loginButton.isEnabled = true
//        } else {
//            loginButton.backgroundColor = .lightGray
//            loginButton.isEnabled = false
//        }
        if isNicknameValid {
            loginButton.backgroundColor = .systemBlue
            loginButton.isEnabled = true
        } else {
            loginButton.backgroundColor = .lightGray
            loginButton.isEnabled = false
        }
    }

    private func configureUI() {
//        view.addSubviews([titleLabel, nicknameField, nicknameUnderline, passwordField, passwordUnderline, statusLabel, loginButton])
        view.addSubviews([titleLabel, floatingLabel, nicknameField, nicknameUnderline, statusLabel, loginButton])
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(50)
        }
        floatingLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(18)
            // 추가 레이아웃 부여하기
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
//        passwordField.snp.makeConstraints { make in
//            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(18)
//            make.height.equalTo(44)
//            make.top.equalTo(nicknameUnderline.snp.bottom).offset(22)
//        }
//        passwordUnderline.snp.makeConstraints { make in
//            make.top.equalTo(passwordField)
//            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(16)
//        }
        statusLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(22)
//            make.top.equalTo(passwordUnderline.snp.bottom).offset(10)
            make.top.equalTo(nicknameUnderline.snp.bottom).offset(10)
        }
        loginButton.snp.makeConstraints { make in
            make.horizontalEdges.bottom.equalTo(view.safeAreaLayoutGuide).inset(22)
            make.height.equalTo(44)
        }
    }
}

extension LoginViewController: UITextFieldDelegate {

    func textFieldDidBeginEditing(_ textField: UITextField) {
        let text = nicknameField.placeholder ?? ""
        // floatingLabel animation
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == nicknameField {
            textField.becomeFirstResponder()
//        } else if textField == passwordField {
//            textField.resignFirstResponder()
//            if loginButton.isEnabled {
//                login()
//            }
        }
        return true
    }
}


// 닉네임 설정만 넣기
// 한글 + 영어만 가능하도록
// 2글자 이상 8글자 이하
// 특수문자 제한
