
import UIKit
import SnapKit

class QnATableViewCell: UITableViewCell {

    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .bk1
        label.font = .systemFont(ofSize: 17)
        label.textAlignment = .left
        label.numberOfLines = 1
        return label
    }()

    let toggleButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        button.tintColor = .bk1
        return button
    }()

    let answerView: UIView = {
        let view = UIView()
        view.isHidden = true
        view.backgroundColor = .sub02
        return view
    }()

    let answerLabel: UILabel = {
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
        contentView.addSubviews([titleLabel, toggleButton, answerView])
        answerView.addSubview(answerLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.trailing.lessThanOrEqualTo(toggleButton.snp.leading).offset(-16)
            make.top.equalToSuperview().offset(20)
        }
        toggleButton.snp.makeConstraints { make in
            make.size.equalTo(17)
            make.trailing.equalToSuperview().inset(20)
            make.centerY.equalTo(titleLabel.snp.centerY)
        }
        answerView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.horizontalEdges.bottom.equalToSuperview()
        }
        answerLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(20)
        }
    }

    func toggleAnswerView(isExpanded: Bool) {
        if isExpanded {
            answerView.isHidden = false
        } else {
            answerView.isHidden = true
        }
    }
}
