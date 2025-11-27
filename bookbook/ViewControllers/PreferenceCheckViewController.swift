
import UIKit
import SnapKit

class PreferenceCheckViewController: UIViewController {

    private var selectedGenres: Set<String> = []
    private let maxSelectCount: Int = 5

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
        button.imageButton(title: "만화//n라이트노벨", image: UIImage(named: "comic_lightnovel"), size: 108)
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
        button.imageButton(title: "전문서적", image: UIImage(named: "professional"), size: 108)
        return button
    }()

    private let skipButton: UIButton = {
        let button = UIButton()
        button.setTitle("취향을 모르겠어요", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.font = .customFont(ofSize: 17, weight: .medium)
        button.tintColor = .customBtn
        button.backgroundColor = .clear
        return button
    }()

    private let nextButton: UIButton = {
        let button = UIButton()
        button.confirmButton(title: "다음", titleColor: .customWh, backColor: .bk4)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureUI()
        buttonActions()
        setupGenreButtons()
        updateNextButtonState()
    }

    private func setupGenreButtons() {
        let genreButtons: [UIButton] = [
            childButton, youthButton, lifeButton,
            hobbyButton, improveButton, historyButton,
            religionButton, economicsButton, itButton,
            comicsButton, eduButton, literatureButton,
            essayButton, artButton, socialButton,
            humanitiesButton, scienceButton, professionalButton
        ]

        genreButtons.forEach { button in
            button.addTarget(self, action: #selector(genreButtonTapped(_:)), for: .touchUpInside)
        }
    }
    @objc private func genreButtonTapped(_ sender: UIButton) {
        guard let title = sender.title(for: .normal) else { return }

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
        print(#function)
        CoreDataManager.shared.selectGenres([])
        let ageVC = UserAgeViewController()
        navigationController?.pushViewController(ageVC, animated: true)
    }
    @objc private func nextButtonTapped() {
        print(#function)
        let genresArray = Array(selectedGenres)
        CoreDataManager.shared.selectGenres(genresArray)
        let ageVC = UserAgeViewController()
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
            make.top.horizontalEdges.equalTo(scrollView)
            make.width.equalTo(scrollView.frameLayoutGuide)
        }
        skipButton.snp.makeConstraints { make in
            make.top.equalTo(biggestStackView.snp.bottom)
            make.centerY.equalTo(scrollView)
        }
        nextButton.snp.makeConstraints { make in
            make.horizontalEdges.bottom.equalTo(view.safeAreaLayoutGuide).inset(16)
        }
    }
}
