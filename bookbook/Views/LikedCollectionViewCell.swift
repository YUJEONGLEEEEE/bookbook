
import UIKit
import SnapKit

class LikedCollectionViewCell: UICollectionViewCell {

    let bookImage: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        return image
    }()

    let bookTitle: UILabel = {
        let label = UILabel()
        label.font = UIFont.customFont(ofSize: 15, weight: .medium)
        label.textAlignment = .left
        label.textColor = .bk1
        label.numberOfLines = 1
        return label
    }()

    let bookAuthor: UILabel = {
        let label = UILabel()
        label.font = UIFont.customFont(ofSize: 14, weight: .medium)
        label.textAlignment = .left
        label.textColor = .bk3
        label.numberOfLines = 1
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .white
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureUI() {
        contentView.addSubviews([bookImage, bookTitle, bookAuthor])
        // 표지 폭은 셀 폭에 맞춘다(고정 102 제거) → 화면 폭이 달라도 옆 셀과 겹치지 않는다.
        bookImage.snp.makeConstraints { make in
            make.height.equalTo(146)
            make.top.horizontalEdges.equalToSuperview()
        }
        bookTitle.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(bookImage.snp.bottom).offset(8)
        }
        bookAuthor.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(bookTitle.snp.bottom).offset(4)
        }
    }
}
