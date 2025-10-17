//
//  UserAgeViewController.swift
//  bookbook
//
//  Created by 이유정 on 9/28/25.
//
// after loginviewcontroller
// choose your age
// page #2

import UIKit
import SnapKit

class UserAgeViewController: UIViewController {

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "연령대를 알려주세요"
        label.titleLabel()
        return label
    }()

    private let ageStackView: UIStackView = {
        let view = UIStackView()
        view.verticalEqualStackView()
        return view
    }()

    private let firstStack: UIStackView = {
        let view = UIStackView()
        view.horizontalEqualStackView()
        return view
    }()

    private let secondStack: UIStackView = {
        let view = UIStackView()
        view.horizontalEqualStackView()
        return view
    }()

    private let childButton: UIButton = {
        let button = UIButton()
        button.imageButton(image: UIImage(named: "children"), title: "어린이")
        return button
    }()

    private let teenButton: UIButton = {
        let button = UIButton()
        button.imageButton(image: UIImage(named: "teenager"), title: "청소년")
        return button
    }()

    private let adultButton: UIButton = {
        let button = UIButton()
        button.imageButton(image: UIImage(named: "adult"), title: "성인")
        return button
    }()

    private let seniorButton: UIButton = {
        let button = UIButton()
        button.imageButton(image: UIImage(named: "senior"), title: "노인")
        return button
    }()

    private let nextButton: UIButton = {
        let button = UIButton()
        button.grayButton(title: "다음")
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureUI()
        buttonActions()
    }

    private func buttonActions() {
        childButton.addTarget(self, action: #selector(childrenButtonClicked), for: .touchUpInside)
        teenButton.addTarget(self, action: #selector(adolescenceButtonClicked), for: .touchUpInside)
        adultButton.addTarget(self, action: #selector(adultButtonClicked), for: .touchUpInside)
        seniorButton.addTarget(self, action: #selector(seniorButtonClicked), for: .touchUpInside)
    }
    @objc private func childrenButtonClicked() {
        print(#function)
    }
    @objc private func adolescenceButtonClicked() {
        print(#function)
    }
    @objc private func adultButtonClicked() {
        print(#function)
    }
    @objc private func seniorButtonClicked() {
        print(#function)
    }

    private func configureUI() {
        view.addSubviews([titleLabel, ageStackView, nextButton])
        ageStackView.addArrangedSubviews([firstStack, secondStack])
        firstStack.addArrangedSubviews([childButton, teenButton])
        secondStack.addArrangedSubviews([adultButton, seniorButton])

        titleLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(30)
        }
        ageStackView.snp.makeConstraints { make in
            make.center.equalTo(view.safeAreaLayoutGuide)
        }
        nextButton.snp.makeConstraints { make in
            make.horizontalEdges.bottom.equalTo(view.safeAreaLayoutGuide).inset(16)
        }
    }
}
