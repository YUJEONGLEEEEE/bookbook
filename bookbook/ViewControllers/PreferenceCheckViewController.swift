//
//  LaunchViewController.swift
//  bookbook
//
//  Created by 이유정 on 9/20/25.
//
// checking book genre preferences
// page #1

import UIKit
import SnapKit

class PreferenceCheckViewController: UIViewController {

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "관심있는 장르를 골라주세요"
        label.titleLabel()
        return label
    }()

    private let subTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "최대 5개까지 선택할 수 있어요"
        return label
    }()

    private let scrollView: UIScrollView = {
        let view = UIScrollView()
        view.scrollsToTop = true
        view.alwaysBounceVertical = true
        view.alwaysBounceHorizontal = false
        view.showsVerticalScrollIndicator = true
        view.showsHorizontalScrollIndicator = false
        return view
    }()

    private let biggestStackView: UIStackView = {
        let view = UIStackView()
        view.verticalEqualStackView()
        return view
    }()

    private let firstStackView: UIStackView = {
        let view = UIStackView()
        view.horizontalEqualStackView()
        return view
    }()

    private let secondStackView: UIStackView = {
        let view = UIStackView()
        view.horizontalEqualStackView()
        return view
    }()

    private let thirdStackView: UIStackView = {
        let view = UIStackView()
        view.horizontalEqualStackView()
        return view
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
        nextButton.addTarget(self, action: #selector(nextButtonClicked), for: .touchUpInside)
    }

    @objc private func nextButtonClicked() {
        print(#function)
        let ageVC = UserAgeViewController()
        navigationController?.pushViewController(ageVC, animated: true)
    }

    private func configureUI() {
        view.addSubviews([titleLabel, subTitleLabel, scrollView, nextButton])
        scrollView.addSubview(biggestStackView)
        biggestStackView.addArrangedSubviews(<#T##views: [UIView]##[UIView]#>)

        titleLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(16) //24
            make.top.equalTo(view.safeAreaLayoutGuide).offset(30)
        }

        subTitleLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
        }

        scrollView.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            make.top.equalTo(subTitleLabel.snp.bottom).offset(20)
            make.bottom.equalTo(nextButton.snp.top).offset(-20)
            make.width.equalTo(view.safeAreaLayoutGuide)
        }

        biggestStackView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView)
            make.width.equalTo(scrollView.frameLayoutGuide)
        }

        nextButton.snp.makeConstraints { make in
            make.horizontalEdges.bottom.equalTo(view.safeAreaLayoutGuide).inset(16)
        }
    }
}
