//
//  UserAgeViewController.swift
//  bookbook
//
//  Created by 이유정 on 9/28/25.
//
// after loginviewcontroller
// choose your age

import UIKit
import SnapKit

class UserAgeViewController: UIViewController {

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "연령대가 어떻게 되시나요?"
        label.textColor = .black
        label.font = .boldSystemFont(ofSize: 34)
        label.textAlignment = .left
        return label
    }()

    private let ageStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.distribution = .fillEqually
        view.spacing = 10
        view.alignment = .center
        return view
    }()

    private let childrenButton: UIButton = {
        let button = UIButton()
        return button
    }()

    private let adolescenceButton: UIButton = {
        let button = UIButton()
        return button
    }()

    private let adultButton: UIButton = {
        let button = UIButton()
        return button
    }()

    private let seniorButton: UIButton = {
        let button = UIButton()
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureUI()
        buttonActions()
    }

    private func buttonActions() {
        childrenButton.addTarget(self, action: #selector(childrenButtonClicked), for: .touchUpInside)
        adolescenceButton.addTarget(self, action: #selector(adolescenceButtonClicked), for: .touchUpInside)
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
        view.addSubviews([titleLabel, ageStackView])
        ageStackView.addArrangedSubviews([childrenButton, adolescenceButton, adultButton, seniorButton])
    }
}
