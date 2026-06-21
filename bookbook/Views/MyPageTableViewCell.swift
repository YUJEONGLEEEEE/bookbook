
import UIKit
import SnapKit

class MyPageTableViewCell: UITableViewCell {

    let menuName: UILabel = {
        let label = UILabel()
        label.textColor = .bk1
        label.textAlignment = .left
        label.font = UIFont.customFont(ofSize: 17, weight: .medium)
        return label
    }()

    let trailingLabel: UILabel = {
        let label = UILabel()
        label.textColor = .bk3
        label.textAlignment = .right
        label.font = UIFont.customFont(ofSize: 15, weight: .medium)
        label.isHidden = true
        return label
    }()

    private let chevron: UIImageView = {
        let view = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)
        view.image = UIImage(systemName: "chevron.right", withConfiguration: config)
        view.tintColor = .bk3
        view.contentMode = .scaleAspectFit
        return view
    }()

    // 프로그래밍 방식 셀: awakeFromNib는 호출되지 않으므로 init에서 UI를 구성한다.
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        configureUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureUI() {
        contentView.addSubviews([menuName, trailingLabel, chevron])

        menuName.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(24)
            make.centerY.equalToSuperview()
        }
        chevron.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(24)
            make.centerY.equalToSuperview()
            make.size.equalTo(16)
        }
        trailingLabel.snp.makeConstraints { make in
            make.trailing.equalTo(chevron.snp.leading).offset(-8)
            make.centerY.equalToSuperview()
        }
    }

    func configure(title: String, trailing: String? = nil) {
        menuName.text = title
        trailingLabel.text = trailing
        trailingLabel.isHidden = (trailing == nil)
    }
}
