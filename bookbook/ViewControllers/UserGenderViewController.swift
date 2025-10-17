//
//  UserGenderViewController.swift
//  bookbook
//
//  Created by 이유정 on 9/28/25.
//
// after userageviewcontroller
// choose your gender
// page #3

import UIKit
import SnapKit

class UserGenderViewController: UIViewController {

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "성별을 알려주세요"
        label.titleLabel()
        return label
    }()

    private let genderStackView: UIStackView = {
        let view = UIStackView()
        view.horizontalEqualStackView()
        return view
    }()

    private let femaleButton: UIButton = {
        let button = UIButton()
        button.imageButton(image: UIImage(named: "female"), title: "여자")
        return button
    }()

    private let maleButton: UIButton = {
        let button = UIButton()
        button.imageButton(image: UIImage(named: "male"), title: "남자")
        return button
    }()

    private let finishButton: UIButton = {
        let button = UIButton()
        button.grayButton(title: "완료")
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureUI()
        buttonActions()
    }

    private func buttonActions() {
        femaleButton.addTarget(self, action: #selector(femaleButtonClicked), for: .touchUpInside)
        maleButton.addTarget(self, action: #selector(maleButtonClicked), for: .touchUpInside)
    }
    @objc private func femaleButtonClicked() {
        print(#function)
    }
    @objc private func maleButtonClicked() {
        print(#function)
    }

    private func configureUI() {
        view.addSubviews([titleLabel, genderStackView, finishButton])
        genderStackView.addArrangedSubviews([femaleButton, maleButton])

        titleLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(30)
        }

        genderStackView.snp.makeConstraints { make in
            make.center.equalTo(view.safeAreaLayoutGuide)
        }
        finishButton.snp.makeConstraints { make in
            make.horizontalEdges.bottom.equalTo(view.safeAreaLayoutGuide).inset(16)
        }
    }
}
