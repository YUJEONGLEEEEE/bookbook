
import UIKit
import SnapKit

final class UserAgeViewController: UIViewController {

    private var selectedAgeRange: AgeRange?
    private weak var selectedButton: UIButton?

    // 편집 모드 원본 스냅샷
    var editContext: PreferenceEditContext?
    // 이전 화면(취향)에서 넘어온 선택 장르 — 저장은 마지막 '완료'에서 한 번에
    var pendingGenres: [String] = []

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.introTitleLabel(title: "연령대를 알려주세요")
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
        button.imageButton(title: "어린이", image: UIImage(named: "children"), size: 170)
        return button
    }()

    private let teenButton: UIButton = {
        let button = UIButton()
        button.imageButton(title: "청소년", image: UIImage(named: "adolescents"), size: 170)
        return button
    }()

    private let secondStack: UIStackView = {
        let view = UIStackView()
        view.horizontalEqualStackView()
        return view
    }()

    private let adultButton: UIButton = {
        let button = UIButton()
        button.imageButton(title: "성인", image: UIImage(named: "adults"), size: 170)
        return button
    }()

    private let seniorButton: UIButton = {
        let button = UIButton()
        button.imageButton(title: "노인", image: UIImage(named: "seniors"), size: 170)
        return button
    }()

    private let nextButton: UIButton = {
        let button = UIButton()
        button.confirmButton(title: "다음", titleColor: .customWh, backColor: .bk4)
        button.isEnabled = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureUI()
        buttonActions()
    }

    // 선택 표시 오버레이는 레이아웃 완료 후 적용
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        preselectSavedAgeIfNeeded()
    }

    // 저장된 연령대 미리 선택
    private func preselectSavedAgeIfNeeded() {
        guard selectedAgeRange == nil,
              let saved = CoreDataManager.shared.fetchAgeRange() else { return }
        let buttonMap: [AgeRange: UIButton] = [
            .child: childButton, .teen: teenButton,
            .adult: adultButton, .senior: seniorButton
        ]
        guard let button = buttonMap[saved] else { return }
        handleAgeSelection(range: saved, button: button)
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
        handleAgeSelection(range: .child, button: childButton)
    }
    @objc private func adolescenceButtonClicked() {
        handleAgeSelection(range: .teen, button: teenButton)
    }
    @objc private func adultButtonClicked() {
        handleAgeSelection(range: .adult, button: adultButton)
    }
    @objc private func seniorButtonClicked() {
        handleAgeSelection(range: .senior, button: seniorButton)
    }
    @objc private func nextButtonClicked() {
        // 더블탭으로 다음 화면이 중복 push되는 것 방지
        guard navigationController?.topViewController === self else { return }
        let vc = UserGenderViewController()
        vc.editContext = editContext
        vc.pendingGenres = pendingGenres
        vc.pendingAge = selectedAgeRange   // 저장은 '완료'에서
        navigationController?.pushViewController(vc, animated: true)
    }
    private func handleAgeSelection(range: AgeRange, button: UIButton) {
        if let prevButton = selectedButton {
            updateButton(prevButton, isSelected: false)
        }
        selectedButton = button
        selectedAgeRange = range
        updateButton(button, isSelected: true)
        // 탭 시 즉시 저장하지 않음 — '완료'에서 일괄 저장(도중 이탈 시 변경 안 남김)
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
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(24)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(24)
        }
        ageStackView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(110)
            make.centerX.equalToSuperview()
        }
        nextButton.snp.makeConstraints { make in
            make.horizontalEdges.bottom.equalTo(view.safeAreaLayoutGuide).inset(16)
        }
    }
}
