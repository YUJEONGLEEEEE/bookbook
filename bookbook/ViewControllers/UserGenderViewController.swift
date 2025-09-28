//
//  UserGenderViewController.swift
//  bookbook
//
//  Created by 이유정 on 9/28/25.
//
// after userageviewcontroller
// choose your gender

import UIKit
import SnapKit

class UserGenderViewController: UIViewController {

    private let titleLabel: UILabel = {
        let label = UILabel()
        return label
    }()

    private let genderStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.distribution = .fillEqually
        view.spacing = 10
        view.alignment = .center
        return view
    }()

    private let femaleButton: UIButton = {
        let button = UIButton()
        return button
    }()

    private let maleButton: UIButton = {
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
        view.addSubviews([titleLabel, genderStackView])
        genderStackView.addArrangedSubviews([femaleButton, maleButton])
    }
}
