
import UIKit
import SnapKit

class NoticeBTableViewCell: UITableViewCell {

    let dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .bk3
        label.textAlignment = .left
        label.numberOfLines = 1
        label.font = UIFont.customFont(ofSize: 14, weight: .medium)
        return label
    }()

    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .bk1
        label.textAlignment = .left
        label.numberOfLines = 1
        label.font = UIFont.customFont(ofSize: 16, weight: .medium)
        return label
    }()

    let toggleButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        button.tintColor = .bk2
        button.isUserInteractionEnabled = false
        return button
    }()

    let descriptionView: UIView = {
        let view = UIView()
        view.isHidden = true
        view.backgroundColor = .sub02
        return view
    }()

    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.numberOfLines = 0
        label.textColor = .bk1
        label.font = UIFont.customFont(ofSize: 15, weight: .medium)
        label.backgroundColor = .clear
        return label
    }()

    private let headerView = UIView()

    private lazy var mainStack: UIStackView = {
        let view = UIStackView(arrangedSubviews: [headerView, descriptionView])
        view.axis = .vertical
        view.spacing = 0
        return view
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        configureUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureUI() {
        headerView.addSubviews([dateLabel, titleLabel, toggleButton])
        dateLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(24)
            make.top.equalToSuperview().offset(16)
        }
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(24)
            make.top.equalTo(dateLabel.snp.bottom).offset(8)
            make.bottom.equalToSuperview().inset(16)
            make.trailing.lessThanOrEqualTo(toggleButton.snp.leading).offset(-16)
        }
        toggleButton.snp.makeConstraints { make in
            make.size.equalTo(20)
            make.trailing.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
        }

        descriptionView.addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(24)
        }

        contentView.addSubview(mainStack)
        mainStack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    func toggleDescriptionView(isExpanded: Bool) {
        descriptionView.isHidden = !isExpanded
        let symbol = isExpanded ? "chevron.up" : "chevron.down"
        toggleButton.setImage(UIImage(systemName: symbol), for: .normal)
    }
}
