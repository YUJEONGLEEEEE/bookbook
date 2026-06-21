
import UIKit
import SnapKit

// 편집 진입 시점의 원본 취향(장르/연령/성별)
struct PreferenceEditContext {
    let genres: Set<String>
    let age: AgeRange?
    let gender: Gender?
}

final class PreferenceCheckViewController: UIViewController {

    private var selectedGenres: Set<String> = []
    private let maxSelectCount: Int = 5

    // 편집 모드 여부
    var isEditMode = false

    // 취소 시 되돌릴 원본 스냅샷
    private var snapshotGenres: [String] = []
    private var snapshotAge: AgeRange?
    private var snapshotGender: Gender?

    // 장르 버튼 목록
    private lazy var genreButtons: [UIButton] = [
        childButton, youthButton, lifeButton,
        hobbyButton, improveButton, historyButton,
        religionButton, economicsButton, itButton,
        comicsButton, eduButton, literatureButton,
        essayButton, artButton, socialButton,
        humanitiesButton, scienceButton, professionalButton
    ]

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.introTitleLabel(title: "어떤 책을 좋아하시나요?")
        return label
    }()

    private let subTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "최대 5개까지 선택할 수 있어요."
        label.font = .customFont(ofSize: 17, weight: .medium)
        label.textColor = .bk2
        label.textAlignment = .left
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

    private let childButton: UIButton = {
        let button = UIButton()
        button.imageButton(title: "아동", image: UIImage(named: "child"), size: 108)
        return button
    }()

    private let youthButton: UIButton = {
        let button = UIButton()
        button.imageButton(title: "청소년", image: UIImage(named: "youth"), size: 108)
        return button
    }()

    private let lifeButton: UIButton = {
        let button = UIButton()
        button.imageButton(title: "가정/생활", image: UIImage(named: "family_life"), size: 108)
        return button
    }()

    private let secondStackView: UIStackView = {
        let view = UIStackView()
        view.horizontalEqualStackView()
        return view
    }()

    private let hobbyButton: UIButton = {
        let button = UIButton()
        button.imageButton(title: "건강/취미", image: UIImage(named: "health_hobby"), size: 108)
        return button
    }()

    private let improveButton: UIButton = {
        let button = UIButton()
        button.imageButton(title: "자기계발", image: UIImage(named: "self_improvement"), size: 108)
        return button
    }()

    private let historyButton: UIButton = {
        let button = UIButton()
        button.imageButton(title: "역사", image: UIImage(named: "history"), size: 108)
        return button
    }()

    private let thirdStackView: UIStackView = {
        let view = UIStackView()
        view.horizontalEqualStackView()
        return view
    }()

    private let religionButton: UIButton = {
        let button = UIButton()
        button.imageButton(title: "종교", image: UIImage(named: "religion"), size: 108)
        return button
    }()

    private let economicsButton: UIButton = {
        let button = UIButton()
        button.imageButton(title: "경제/경영", image: UIImage(named: "economy_management"), size: 108)
        return button
    }()

    private let itButton: UIButton = {
        let button = UIButton()
        button.imageButton(title: "컴퓨터/IT", image: UIImage(named: "computer_it"), size: 108)
        return button
    }()

    private let fourthStackView: UIStackView = {
        let view = UIStackView()
        view.horizontalEqualStackView()
        return view
    }()

    private let comicsButton: UIButton = {
        let button = UIButton()
        // 길어서 2줄 표시
        button.imageButton(title: "만화/\n라이트노벨", image: UIImage(named: "comic_lightnovel"), size: 108)
        button.titleLabel?.numberOfLines = 2
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.lineBreakMode = .byCharWrapping
        return button
    }()

    private let eduButton: UIButton = {
        let button = UIButton()
        button.imageButton(title: "교육", image: UIImage(named: "education"), size: 108)
        return button
    }()

    private let literatureButton: UIButton = {
        let button = UIButton()
        button.imageButton(title: "문학", image: UIImage(named: "literature"), size: 108)
        return button
    }()

    private let fifthStackView: UIStackView = {
        let view = UIStackView()
        view.horizontalEqualStackView()
        return view
    }()

    private let essayButton: UIButton = {
        let button = UIButton()
        button.imageButton(title: "에세이", image: UIImage(named: "essay"), size: 108)
        return button
    }()

    private let artButton: UIButton = {
        let button = UIButton()
        button.imageButton(title: "예술", image: UIImage(named: "art"), size: 108)
        return button
    }()

    private let socialButton: UIButton = {
        let button = UIButton()
        button.imageButton(title: "사회과학", image: UIImage(named: "social_science"), size: 108)
        return button
    }()

    private let sixthStackView: UIStackView = {
        let view = UIStackView()
        view.horizontalEqualStackView()
        return view
    }()

    private let humanitiesButton: UIButton = {
        let button = UIButton()
        button.imageButton(title: "인문학", image: UIImage(named: "humanities"), size: 108)
        return button
    }()

    private let scienceButton: UIButton = {
        let button = UIButton()
        button.imageButton(title: "과학/공학", image: UIImage(named: "science_engineering"), size: 108)
        return button
    }()

    private let professionalButton: UIButton = {
        let button = UIButton()
        button.imageButton(title: "전문서적", image: UIImage(named: "specialty_publication"), size: 108)
        return button
    }()

    private let skipButton: UIButton = {
        let button = UIButton()
        button.setTitle("취향을 모르겠어요", for: .normal)
        button.setTitleColor(.customBtn, for: .normal)
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.font = .customFont(ofSize: 17, weight: .medium)
        button.tintColor = .customBtn
        button.backgroundColor = .clear
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
        navigationItem.hidesBackButton = true
        configureUI()
        buttonActions()
        setupGenreButtons()

        if isEditMode {
            setupCancelButton()
            loadSavedGenres()
            snapshotCurrentChoices()
        } else {
            setupLogoutButton()
        }
        updateNextButtonState()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isEditMode { applyGenreSelectionOverlays() }
    }

    // 환영 토스트는 취향선택이 아니라 튜토리얼 이후 메인 진입 시 표시 (MainViewController.viewDidAppear)

    // MARK: - 편집(취소) 처리

    private func setupCancelButton() {
        let button = UIBarButtonItem(title: "취소", style: .plain, target: self, action: #selector(cancelButtonTapped))
        button.tintColor = .bk3
        if #available(iOS 26.0, *) {
            button.hidesSharedBackground = true
        }
        navigationItem.rightBarButtonItem = button
    }
    @objc private func cancelButtonTapped() {
        // 스냅샷으로 원본 복원
        CoreDataManager.shared.selectGenres(snapshotGenres)
        if let age = snapshotAge { CoreDataManager.shared.updateAgeRange(age) }
        if let gender = snapshotGender { CoreDataManager.shared.updateGender(gender) }
        navigationController?.popViewController(animated: true)
    }

    // 저장된 장르 불러오기
    private func loadSavedGenres() {
        selectedGenres = Set(CoreDataManager.shared.fetchGenres())
    }

    // 장르 선택 오버레이 적용
    private func applyGenreSelectionOverlays() {
        genreButtons.forEach { button in
            let key = button.title(for: .normal)?.replacingOccurrences(of: "\n", with: "") ?? ""
            button.setSelectedOverlay(selectedGenres.contains(key))
        }
    }

    private func snapshotCurrentChoices() {
        snapshotGenres = CoreDataManager.shared.fetchGenres()
        snapshotAge = CoreDataManager.shared.fetchAgeRange()
        snapshotGender = CoreDataManager.shared.fetchGender()
    }

    private func setupLogoutButton() {
        let button = UIBarButtonItem(title: "로그아웃", style: .plain, target: self, action: #selector(logoutButtonTapped))
        button.tintColor = .bk3
        // iOS 26: 바 버튼 글래스 배경 제거
        if #available(iOS 26.0, *) {
            button.hidesSharedBackground = true
        }
        navigationItem.rightBarButtonItem = button
    }
    @objc private func logoutButtonTapped() {
        alertWithCancel(message: "로그아웃하시겠습니까?") {
            // 세션만 정리(계정 유지)
            UserSession.clear()
            guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = scene.windows.first else { return }
            window.rootViewController = AuthNavigationController(rootViewController: SignUpViewController())
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
            window.makeKeyAndVisible()
        }
    }

    private func setupGenreButtons() {
        genreButtons.forEach { button in
            button.addTarget(self, action: #selector(genreButtonTapped(_:)), for: .touchUpInside)
        }
    }
    @objc private func genreButtonTapped(_ sender: UIButton) {
        // 줄바꿈 제거해 저장/매칭용 표준 장르 키 생성
        guard let title = sender.title(for: .normal)?.replacingOccurrences(of: "\n", with: "") else { return }

        if selectedGenres.contains(title) {
            selectedGenres.remove(title)
            updateButton(sender, isSelected: false)
        } else {
            guard selectedGenres.count < maxSelectCount else { return }
            selectedGenres.insert(title)
            updateButton(sender, isSelected: true)
        }
        updateNextButtonState()
    }

    private func updateButton(_ button: UIButton, isSelected: Bool) {
        button.setSelectedOverlay(isSelected)
    }

    private func buttonActions() {
        skipButton.addTarget(self, action: #selector(skipButtonTapped), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
    }
    @objc private func skipButtonTapped() {
        debugLog(#function)
        CoreDataManager.shared.selectGenres([])
        pushAgeViewController()
    }
    @objc private func nextButtonTapped() {
        debugLog(#function)
        let genresArray = Array(selectedGenres)
        CoreDataManager.shared.selectGenres(genresArray)
        pushAgeViewController()
    }

    private func pushAgeViewController() {
        let ageVC = UserAgeViewController()
        // 편집 모드면 원본 스냅샷 전달
        if isEditMode {
            ageVC.editContext = PreferenceEditContext(
                genres: Set(snapshotGenres),
                age: snapshotAge,
                gender: snapshotGender
            )
        }
        navigationController?.pushViewController(ageVC, animated: true)
    }

    private func updateNextButtonState() {
        if selectedGenres.isEmpty {
            nextButton.isEnabled = false
            nextButton.backgroundColor = .bk4
        } else {
            nextButton.isEnabled = true
            nextButton.backgroundColor = .customMain
        }
    }

    private func configureUI() {
        view.addSubviews([titleLabel, subTitleLabel, scrollView, nextButton])
        scrollView.addSubviews([biggestStackView, skipButton])
        biggestStackView.addArrangedSubviews([firstStackView, secondStackView, thirdStackView, fourthStackView, fifthStackView, sixthStackView])
        firstStackView.addArrangedSubviews([childButton, youthButton, lifeButton])
        secondStackView.addArrangedSubviews([hobbyButton, improveButton, historyButton])
        thirdStackView.addArrangedSubviews([religionButton, economicsButton, itButton])
        fourthStackView.addArrangedSubviews([comicsButton, eduButton, literatureButton])
        fifthStackView.addArrangedSubviews([essayButton, artButton, socialButton])
        sixthStackView.addArrangedSubviews([humanitiesButton, scienceButton, professionalButton])
        titleLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(24)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(24)
        }
        subTitleLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(24)
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
        }
        scrollView.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            make.top.equalTo(subTitleLabel.snp.bottom).offset(20)
            make.bottom.equalTo(nextButton.snp.top).offset(-20)
        }
        biggestStackView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(scrollView)
            make.width.equalTo(scrollView.frameLayoutGuide)
        }
        skipButton.snp.makeConstraints { make in
            make.top.equalTo(biggestStackView.snp.bottom).offset(46)
            make.centerX.equalTo(scrollView.frameLayoutGuide)
            make.bottom.equalTo(scrollView.contentLayoutGuide).offset(-20)
        }
        nextButton.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
}
