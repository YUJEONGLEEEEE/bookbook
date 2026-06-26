
import UIKit
import Kingfisher
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
        image.contentMode = .scaleAspectFill
        image.backgroundColor = .bk5
        return image
    }()

    let bookTitle: UILabel = {
        let label = UILabel()
        label.font = UIFont.customFont(ofSize: 18, weight: .medium)
        label.textColor = .bk1
        label.textAlignment = .left
        return label
    }()

    let bookAuthorPublisher: UILabel = {
        let label = UILabel()
        label.font = UIFont.customFont(ofSize: 16, weight: .regular)
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

    override func prepareForReuse() {
        super.prepareForReuse()
        bookImage.kf.cancelDownloadTask()
        bookImage.image = nil
        bookTitle.text = nil
        bookAuthorPublisher.text = nil
        bookRank.text = nil
        showLiked.showLikedCounts(count: 0)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureUI() {
        bookImage.layer.cornerRadius = 4
        bookImage.clipsToBounds = true

        contentView.addSubviews([bookRank, bookImage, bookTitle, bookAuthorPublisher, showLiked])
        bookRank.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalTo(bookImage.snp.top)
            make.width.equalTo(24)
        }
        bookImage.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(27)
            make.top.bottom.equalToSuperview()
            make.width.equalTo(78)
        }
        bookTitle.snp.makeConstraints { make in
            make.leading.equalTo(bookImage.snp.trailing).offset(16)
            make.top.equalTo(bookImage.snp.top)
            make.trailing.equalToSuperview().inset(16)
        }
        bookAuthorPublisher.snp.makeConstraints { make in
            make.leading.equalTo(bookImage.snp.trailing).offset(16)
            make.top.equalTo(bookTitle.snp.bottom).offset(4)
            make.trailing.lessThanOrEqualToSuperview().inset(16)
        }
        showLiked.snp.makeConstraints { make in
            make.leading.equalTo(bookTitle.snp.leading).offset(-5)
            make.top.equalToSuperview().offset(80)
        }
    }
}
