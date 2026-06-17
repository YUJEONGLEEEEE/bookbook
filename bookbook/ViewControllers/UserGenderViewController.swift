
import UIKit
import SnapKit

final class UserGenderViewController: UIViewController {

    private var selectedGender: Gender?
    private weak var selectedButton: UIButton?

    var editContext: PreferenceEditContext?

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.introTitleLabel(title: "성별을 알려주세요")
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
        button.confirmButton(title: "완료", titleColor: .customWh, backColor: .bk4)
        button.isEnabled = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureUI()
        buttonActions()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        preselectSavedGenderIfNeeded()
        updateFinishButtonState()
    }

    private func preselectSavedGenderIfNeeded() {
        guard selectedGender == nil,
              let saved = CoreDataManager.shared.fetchGender() else { return }
        let button = (saved == .male) ? maleButton : femaleButton
        handleGenderSelection(gender: saved, button: button)
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
        if UserSession.hasSeenTutorial {
            // 편집(내취향 > 편집)으로 진입한 경우엔 메인에서 '취향 변경' 토스트
            if editContext != nil {
                ToastManager.shared.pendingMessage = "취향이 변경되었어요"
            }
            MainTabBarController.setAsRoot()
        } else {
            let tutorialVC = OnboardingViewController()
            navigationController?.setViewControllers([tutorialVC], animated: true)
        }
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
        let enabled: Bool
        if selectedGender == nil {
            enabled = false
        } else if let ctx = editContext {
            // 편집 모드: 장르·연령·성별 중 하나라도 원본과 달라야 활성화
            enabled = hasAnyChange(from: ctx)
        } else {
            // 온보딩: 성별만 선택하면 활성화
            enabled = true
        }
        finishButton.isEnabled = enabled
        finishButton.backgroundColor = enabled ? .customMain : .bk4
    }

    private func hasAnyChange(from ctx: PreferenceEditContext) -> Bool {
        let currentGenres = Set(CoreDataManager.shared.fetchGenres())
        let currentAge = CoreDataManager.shared.fetchAgeRange()
        return currentGenres != ctx.genres
            || currentAge != ctx.age
            || selectedGender != ctx.gender
    }

    private func configureUI() {
        view.addSubviews([titleLabel, genderStackView, finishButton])
        // Figma 순서: 여자(좌) · 남자(우)
        genderStackView.addArrangedSubviews([femaleButton, maleButton])

        titleLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(24)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(24)
        }
        genderStackView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(110)
            make.centerX.equalToSuperview()
        }
        finishButton.snp.makeConstraints { make in
            make.horizontalEdges.bottom.equalTo(view.safeAreaLayoutGuide).inset(16)
        }
    }
}
