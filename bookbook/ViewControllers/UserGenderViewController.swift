
import UIKit
import SnapKit

class UserGenderViewController: UIViewController {

    private var selectedGender: Gender?
    private weak var selectedButton: UIButton?

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "성별을 알려주세요"
        label.checkTitleLabel()
        return label
    }()

    private let genderStackView: UIStackView = {
        let view = UIStackView()
        view.horizontalEqualStackView()
        return view
    }()

    private let maleButton: UIButton = {
        let button = UIButton()
        button.imageButton(title: "남자", image: UIImage(named: "male"), size: 170)
        return button
    }()

    private let femaleButton: UIButton = {
        let button = UIButton()
        button.imageButton(title: "여자", image: UIImage(named: "female"), size: 170)
        return button
    }()

    private let finishButton: UIButton = {
        let button = UIButton()
        button.confirmButton(title: "완료")
        button.isEnabled = false
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
        femaleButton.addTarget(self, action: #selector(femaleButtonClicked), for: .touchUpInside)
        maleButton.addTarget(self, action: #selector(maleButtonClicked), for: .touchUpInside)
        finishButton.addTarget(self, action: #selector(finishButtonClicked), for: .touchUpInside)
    }
    @objc private func maleButtonClicked() {
        print(#function)
        handleGenderSelection(gender: .male, button: maleButton)
    }
    @objc private func femaleButtonClicked() {
        print(#function)
        handleGenderSelection(gender: .female, button: femaleButton)
    }
    @objc private func finishButtonClicked() {
        print(#function)
        let vc = MainViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    private func handleGenderSelection(gender: Gender, button: UIButton) {
        if let prevButton = selectedButton {
            updateButton(prevButton, isSelected: false)
        }
        selectedButton = button
        selectedGender = gender
        updateButton(button, isSelected: true)

        CoreDataManager.shared.updateGender(gender)
        updateFinishButtonState()
    }
    private func updateFinishButtonState() {
        if selectedGender == nil {
            finishButton.isEnabled = false
            finishButton.backgroundColor = .bk4
        } else {
            finishButton.isEnabled = true
            finishButton.backgroundColor = .customMain
        }
    }

    private func configureUI() {
        view.addSubviews([titleLabel, genderStackView, finishButton])
        genderStackView.addArrangedSubviews([maleButton, femaleButton])

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
