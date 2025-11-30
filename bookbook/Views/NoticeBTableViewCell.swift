
import UIKit
import SnapKit

class NoticeBTableViewCell: UITableViewCell {

    let dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .bk3
        label.textAlignment = .left
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 15)
        return label
    }()

    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .bk1
        label.textAlignment = .left
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 17)
        return label
    }()

    let toggleButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        button.tintColor = .bk1
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
        label.backgroundColor = .clear
        return label
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        configureUI()
    }

    private func configureUI() {
        contentView.addSubviews([dateLabel, titleLabel, toggleButton, descriptionView])
        descriptionView.addSubview(descriptionLabel)
        dateLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().offset(24)
            make.top.equalToSuperview().offset(16)
        }
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalTo(toggleButton.snp.leading).offset(-24)
            make.top.equalTo(dateLabel.snp.bottom).offset(10)
        }
        toggleButton.snp.makeConstraints { make in
            make.size.equalTo(24)
            make.trailing.equalToSuperview().inset(20)
            make.centerY.equalTo(titleLabel.snp.centerY)
        }
        descriptionView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.horizontalEdges.bottom.equalToSuperview()
        }
        descriptionLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(24)
        }
    }

    func toggleDescriptionView(isExpanded: Bool) {
        if isExpanded {
            descriptionView.isHidden = false
        } else {
            descriptionView.isHidden = true
        }
    }
}
