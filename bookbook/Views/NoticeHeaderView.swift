
import UIKit
import SnapKit

class NoticeHeaderView: UITableViewHeaderFooterView {

    weak var delegate: NoticeHeaderViewProtocol?

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "공지사항"
        label.textColor = .bk1
        label.font = .boldSystemFont(ofSize: 17)
        label.textAlignment = .left
        return label
    }()

    private let moreButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.tintColor = .bk1
        return button
    }()

    private let boldSeparator: UIView = {
        let view = UIView()
        view.addBoldLine()
        return view
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
        self.addSubviews([titleLabel, moreButton, boldSeparator])
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
        }
        moreButton.snp.makeConstraints { make in
            make.size.equalTo(17)
            make.trailing.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
        }
        boldSeparator.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
        }
    }
}
