
import UIKit
import SnapKit

class QnAHeaderView: UITableViewHeaderFooterView {

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "자주 묻는 질문"
        label.textColor = .bk1
        label.textAlignment = .left
        label.font = .boldSystemFont(ofSize: 17)
        return label
    }()

    private let boldSeparator: UIView = {
        let view = UIView()
        view.addBoldLine()
        return view
    }()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureUI() {
        self.addSubviews([titleLabel, boldSeparator])
        titleLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
        }
        boldSeparator.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
        }
    }
}
