import UIKit
import SnapKit

class SearchedHeaderView: UICollectionReusableView {

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = .bk1
        label.font = UIFont.customFont(ofSize: 16, weight: .bold)
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureUI() {
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.verticalEdges.leading.equalToSuperview()
        }
    }

    func configure(title: String) {
        titleLabel.text = title
    }
}
