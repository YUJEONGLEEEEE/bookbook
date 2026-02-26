// searchviewcontroller -> 책 검색결과 정렬 && 검색결과 총 갯수

import UIKit
import SnapKit

class BookSortView: UIView {

    weak var delegate: BookSortProtocol?

    private var currentSort: BookSortOption = .accuracy
    private var allButtons: [UIButton] {
        [accuracyButton, recommendButton, latestButton]
    }

    private lazy var sortStack: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 16
        view.alignment = .center
        return view
    }()
    private let accuracyButton = UIButton(type: .system)
    private let recommendButton = UIButton(type: .system)
    private let latestButton = UIButton(type: .system)

    private let totalCountLabel: UILabel = {
        let label = UILabel()
        label.textColor = .bk2
        label.font = UIFont.customFont(ofSize: 14, weight: .medium)
        label.textAlignment = .right
        label.numberOfLines = 1
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
        buttonActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateTotalCount(_ count: Int) {
        let formatted = NumberFormatter.countFormatter
            .string(from: NSNumber(value: count)) ?? "0"

        totalCountLabel.text = "\(formatted)권"
    }

    private func buttonActions() {
        accuracyButton.addTarget(self, action: #selector(accuracyButtonTapped), for: .touchUpInside)
        recommendButton.addTarget(self, action: #selector(recommendButtonTapped), for: .touchUpInside)
        latestButton.addTarget(self, action: #selector(latestButtonTapped), for: .touchUpInside)
    }
    @objc private func accuracyButtonTapped() {
        print(#function)
        guard currentSort != .accuracy else { return }
        updateSelectedButton(.accuracy)
        delegate?.sortView(self, didSelect: .accuracy)
    }
    @objc private func recommendButtonTapped(){
        print(#function)
        guard currentSort != .recommend else { return }
        updateSelectedButton(.recommend)
        delegate?.sortView(self, didSelect: .recommend)
    }
    @objc private func latestButtonTapped() {
        print(#function)
        guard currentSort != .latest else { return }
        updateSelectedButton(.latest)
        delegate?.sortView(self, didSelect: .latest)
    }
    func updateSelectedButton(_ sort: BookSortOption) {
        currentSort = sort
        
        allButtons.forEach {
            $0.setTitleColor(.bk3, for: .normal)
            $0.titleLabel?.font = UIFont.customFont(ofSize: 14, weight: .medium)
        }

        let selectedSort: UIButton
        switch sort {
        case .accuracy: selectedSort = accuracyButton
        case .recommend: selectedSort = recommendButton
        case .latest: selectedSort = latestButton
        }
        selectedSort.setTitleColor(.bk1, for: .normal)
        selectedSort.titleLabel?.font = UIFont.customFont(ofSize: 14, weight: .bold)
    }

    private func configureUI() {
        backgroundColor = .clear
        
        addSubviews([sortStack, totalCountLabel])
        sortStack.addArrangedSubviews([accuracyButton, recommendButton, latestButton])
        sortStack.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(24)
            make.centerY.equalToSuperview()
        }
        totalCountLabel.snp.makeConstraints { make in
            make.leading.greaterThanOrEqualTo(sortStack.snp.trailing).offset(12)
            make.trailing.equalToSuperview().inset(24)
            make.centerY.equalToSuperview()
        }

        sortStack.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        totalCountLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        [accuracyButton, recommendButton, latestButton].forEach { button in
            button.titleLabel?.font = UIFont.customFont(ofSize: 14, weight: .medium)
            button.setTitleColor(.bk3, for: .normal)
        }
        accuracyButton.setTitle(BookSortOption.accuracy.title, for: .normal)
        recommendButton.setTitle(BookSortOption.recommend.title, for: .normal)
        latestButton.setTitle(BookSortOption.latest.title, for: .normal)

        accuracyButton.accessibilityIdentifier = "accuracyButton"
        recommendButton.accessibilityIdentifier = "recommendButton"
        latestButton.accessibilityIdentifier = "latestButton"

        updateSelectedButton(.accuracy)
    }
}
