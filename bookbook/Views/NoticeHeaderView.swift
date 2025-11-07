
import UIKit
import SnapKit

class NoticeHeaderView: UITableViewHeaderFooterView {

    weak var delegate: NoticeHeaderViewProtocol?

    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "공지사항"
        label.textColor = .bk1
        label.font = .boldSystemFont(ofSize: 17)
        label.textAlignment = .left
        return label
    }()

    let moreButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.tintColor = .bk1
        return button
    }()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        configureUI()
        moreButton.addTarget(self, action: #selector(moreButtonTapped), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func moreButtonTapped() {
        print(#function)
        delegate?.headerViewButtonTapped(self)
    }

    private func configureUI() {
        self.addSubviews([titleLabel, moreButton])
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }
        moreButton.snp.makeConstraints { make in
            make.size.equalTo(17)
            make.trailing.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
        }
    }
}
