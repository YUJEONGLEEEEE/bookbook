
import UIKit
import SnapKit

class BookRankingCollectionViewCell: UICollectionViewCell {

    let bookRank: UILabel = {
        let label = UILabel()
        label.textColor =  .bk2
        label.font = UIFont.customFont(ofSize: 30, weight: .medium)
        label.textAlignment = .center
        return label
    }()

    let bookImage: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        return image
    }()

    let bookTitle: UILabel = {
        let label = UILabel()
        label.font = UIFont.customFont(ofSize: 17, weight: .medium)
        label.textColor = .bk1
        label.textAlignment = .left
        return label
    }()

    let bookAuthorPublisher: UILabel = {
        let label = UILabel()
        label.font = UIFont.customFont(ofSize: 16, weight: .medium)
        label.textColor = .bk3
        label.textAlignment = .left
        return label
    }()

    let showLiked: UIButton = {
        let button = UIButton()
        button.showLikedCounts(count: 0)
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        addSubviews([bookRank, bookImage, bookTitle, bookAuthorPublisher, showLiked])
        bookRank.snp.makeConstraints { make in
            make.leading.equalToSuperview()
        }
        bookImage.snp.makeConstraints { make in
            make.height.equalTo(112)
            make.width.equalTo(78)
            make.leading.equalTo(bookRank.snp.trailing).offset(15)
            make.top.equalToSuperview()
        }
        bookTitle.snp.makeConstraints { make in
            make.leading.equalTo(bookImage.snp.trailing).offset(16)
            make.top.equalToSuperview()
            make.trailing.equalToSuperview().inset(16)
        }
        bookAuthorPublisher.snp.makeConstraints { make in
            make.leading.equalTo(bookImage.snp.trailing).offset(16)
            make.top.equalTo(bookTitle.snp.bottom).offset(4)
            make.trailing.equalToSuperview().inset(16)
        }
        showLiked.snp.makeConstraints { make in
            make.top.equalTo(bookAuthorPublisher.snp.bottom).offset(35)
            make.leading.equalTo(bookImage.snp.trailing).offset(16)
            make.height.equalTo(32)
            make.width.equalTo(49)
        }
    }
}
