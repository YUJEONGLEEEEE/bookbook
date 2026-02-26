// SearchViewController - RecentSearchedCollectionViewCell, PopularSearchedCollectionViewCell

import UIKit
import SnapKit

class SearchedHeaderView: UICollectionReusableView {

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = .black
        label.font = .boldSystemFont(ofSize: 17)
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureUI() {
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(10)
        }
    }

    func configure(title: String) {
        titleLabel.text = title
    }
}
