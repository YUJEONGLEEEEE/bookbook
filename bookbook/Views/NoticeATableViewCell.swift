
import UIKit
import SnapKit

class NoticeATableViewCell: UITableViewCell {

    let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = .customFont(ofSize: 17)
        label.textColor = .bk1
        label.numberOfLines = 1
        return label
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
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
        }
    }

}
