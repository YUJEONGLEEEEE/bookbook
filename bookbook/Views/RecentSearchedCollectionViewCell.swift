import UIKit
import SnapKit

class RecentSearchedCollectionViewCell: UICollectionViewCell {

    var deleteAction: (() -> Void)?

    private let stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.alignment = .center
        view.spacing = 6
        return view
    }()

    let wordLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.customFont(ofSize: 14, weight: .medium)
        label.textColor = .bk1
        label.numberOfLines = 1
        return label
    }()

    let deleteButton: UIButton = {
        let button = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: 10, weight: .medium)
        button.setImage(UIImage(systemName: "xmark", withConfiguration: config), for: .normal)
        button.tintColor = .bk3
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        configureUI()
    }
    @objc private func deleteButtonTapped() {
        deleteAction?()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // 높이의 1/2 → 캡슐형
        contentView.layer.cornerRadius = contentView.bounds.height / 2
    }

    private func configureUI() {
        contentView.backgroundColor = .customWh
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.bk6.cgColor
        contentView.layer.masksToBounds = true

        contentView.addSubview(stackView)
        stackView.addArrangedSubviews([wordLabel, deleteButton])

        deleteButton.snp.makeConstraints { make in
            make.size.equalTo(16)
        }
        stackView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(16)
            make.trailing.equalToSuperview().inset(12)
            make.centerY.equalToSuperview()
        }
        wordLabel.setContentHuggingPriority(.required, for: .horizontal)
    }
}
