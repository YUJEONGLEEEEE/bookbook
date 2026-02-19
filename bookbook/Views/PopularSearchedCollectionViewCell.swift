// SearchViewController - SearchedCollectionView section2

import UIKit
import SnapKit

class PopularSearchedCollectionViewCell: UICollectionViewCell {

    private let keywordLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureUI() {
        contentView.addSubview(keywordLabel)
        contentView.layer.borderWidth = 1
        contentView.layer.cornerRadius = 24
        contentView.layer.masksToBounds = true

        keywordLabel.font = UIFont.customFont(ofSize: 14, weight: .medium)
        keywordLabel.textAlignment = .center
        keywordLabel.numberOfLines = 1

        keywordLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.verticalEdges.equalToSuperview().inset(8)
            make.height.equalTo(33)
        }
    }

    func configureKeywordLabel(with text: String, index: Int) {
        keywordLabel.text = "#\(text)"

        let style = KeywordStyle.cycled(for: index)
        contentView.layer.borderColor = style.borderColor.cgColor
        keywordLabel.textColor = style.textColor
        contentView.backgroundColor = style.backgroundColor
    }
}
