
import UIKit
import SnapKit

final class UserGenderViewController: UIViewController {

    private var selectedGender: Gender?
    private weak var selectedButton: UIButton?

    var editContext: PreferenceEditContext?
    // 이전 화면들에서 넘어온 선택 — 저장은 '완료'에서 한 번에
    var pendingGenres: [String] = []
    var pendingAge: AgeRange?

    // '완료' 더블탭으로 저장·화면전환이 중복 실행되는 것 방지
    private var isFinishing = false

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
        debugLog(#function)
        handleGenderSelection(gender: .male, button: maleButton)
    }
    @objc private func femaleButtonClicked() {
        debugLog(#function)
        handleGenderSelection(gender: .female, button: femaleButton)
    }
    @objc private func finishButtonClicked() {
        guard !isFinishing else { return }
        isFinishing = true
        // '완료' 시점에 장르·연령·성별을 한 번에 저장 (탭마다 저장하지 않음 → 도중 이탈 시 변경 안 남김)
        CoreDataManager.shared.selectGenres(pendingGenres)
        if let age = pendingAge { CoreDataManager.shared.updateAgeRange(age) }
        if let gender = selectedGender { CoreDataManager.shared.updateGender(gender) }

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
        // 탭 시 즉시 저장하지 않음 — '완료'에서 일괄 저장
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
        // 저장 전이므로 DB가 아니라 '대기 중인 선택값'으로 변경 여부 판단
        return Set(pendingGenres) != ctx.genres
            || pendingAge != ctx.age
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
