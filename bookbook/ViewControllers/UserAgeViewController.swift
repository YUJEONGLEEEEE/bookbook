
import UIKit
import SnapKit

class UserAgeViewController: UIViewController {

    private var selectedAgeRange: AgeRange?
    private weak var selectedButton: UIButton?

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "연령대를 알려주세요"
        label.checkTitleLabel()
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

    private let childButton: UIButton = {
        let button = UIButton()
        button.imageButton(title: "어린이", image: UIImage(named: "child"), size: 170)
        return button
    }()

    private let teenButton: UIButton = {
        let button = UIButton()
        button.imageButton(title: "청소년", image: UIImage(named: "youth"), size: 170)
        return button
    }()

    private let secondStack: UIStackView = {
        let view = UIStackView()
        view.horizontalEqualStackView()
        return view
    }()

    private let adultButton: UIButton = {
        let button = UIButton()
        button.imageButton(title: "성인", image: UIImage(named: "adult"), size: 170)
        return button
    }()

    private let seniorButton: UIButton = {
        let button = UIButton()
        button.imageButton(title: "노인", image: UIImage(named: "senior"), size: 170)
        return button
    }()

    private let nextButton: UIButton = {
        let button = UIButton()
        button.confirmButton(title: "다음")
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureUI()
        buttonActions()
    }

    private func updateButton(_ button: UIButton, isSelected: Bool) {
        button.setSelectedOverlay(isSelected)
    }

    private func buttonActions() {
        childButton.addTarget(self, action: #selector(childrenButtonClicked), for: .touchUpInside)
        teenButton.addTarget(self, action: #selector(adolescenceButtonClicked), for: .touchUpInside)
        adultButton.addTarget(self, action: #selector(adultButtonClicked), for: .touchUpInside)
        seniorButton.addTarget(self, action: #selector(seniorButtonClicked), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(nextButtonClicked), for: .touchUpInside)
    }
    @objc private func childrenButtonClicked() {
        print(#function)
        handleAgeSelection(range: .child, button: childButton)
    }
    @objc private func adolescenceButtonClicked() {
        print(#function)
        handleAgeSelection(range: .teen, button: teenButton)
    }
    @objc private func adultButtonClicked() {
        print(#function)
        handleAgeSelection(range: .adult, button: adultButton)
    }
    @objc private func seniorButtonClicked() {
        print(#function)
        handleAgeSelection(range: .senior, button: seniorButton)
    }
    @objc private func nextButtonClicked() {
        print(#function)
        let vc = UserGenderViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    private func handleAgeSelection(range: AgeRange, button: UIButton) {
        if let prevButton = selectedButton {
            updateButton(prevButton, isSelected: false)
        }
        selectedButton = button
        selectedAgeRange = range
        updateButton(button, isSelected: true)

        CoreDataManager.shared.updateAgeRange(range)
        updateNextButtonState()
    }
    private func updateNextButtonState() {
        if selectedAgeRange == nil {
            nextButton.isEnabled = false
            nextButton.backgroundColor = .bk4
        } else {
            nextButton.isEnabled = true
            nextButton.backgroundColor = .customMain
        }
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
