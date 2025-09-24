//
//  LoginViewController.swift
//  bookbook
//
//  Created by 이유정 on 9/24/25.
//

import UIKit
import SnapKit

class LoginViewController: UIViewController {

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
        field.placeholder = "사용할 닉네임을 만들어주세요"
        field.textColor = .black
        field.textAlignment = .left
        field.keyboardType = .default
        field.font = .systemFont(ofSize: 17)
        return field
    }()

    private let nicknameUnderline: UIView = {
        let view = UIView()
        view.addUnderline()
        return view
    }()

    private let passwordField: UITextField = {
        let field = UITextField()
        field.placeholder = "비밀번호를 입력해주세요"
        field.textColor = .black
        field.textAlignment = .left
        field.keyboardType = .default
        field.font = .systemFont(ofSize: 17)
        return field
    }()

    private let passwordUnderline: UIView = {
        let view = UIView()
        view.addUnderline()
        return view
    }()

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
        button.backgroundColor = .systemBlue
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

    }

    private func configureUI() {
        view.addSubviews([titleLabel, nicknameField, nicknameUnderline, passwordField, passwordUnderline, statusLabel, loginButton])
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(50)
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
        passwordField.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(18)
            make.height.equalTo(44)
            make.top.equalTo(nicknameUnderline.snp.bottom).offset(22)
        }
        passwordUnderline.snp.makeConstraints { make in
            make.top.equalTo(passwordField)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(16)
        }
        statusLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(22)
            make.top.equalTo(passwordUnderline.snp.bottom).offset(10)
        }
        loginButton.snp.makeConstraints { make in
            make.horizontalEdges.bottom.equalTo(view.safeAreaLayoutGuide).inset(22)
            make.height.equalTo(44)
        }
    }


}
