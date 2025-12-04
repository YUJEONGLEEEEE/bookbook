
import UIKit
import SnapKit

class BookRankingCollectionViewCell: UICollectionViewCell {

    private let bookRank: UILabel = {
        let label = UILabel()
        return label
    }()

    private let bookImage: UIImageView = {
        let image = UIImageView()
        return image
    }()

    private let bookTitle: UILabel = {
        let label = UILabel()
        label.font = UIFont.customFont(ofSize: 17, weight: .medium)
        label.textColor = .bk1
        label.textAlignment = .left
        return label
    }()

    private let bookAuthorPublisher: UILabel = {
        let label = UILabel()
        return label
    }()

    private let showLiked: UIButton = {
        let button = UIButton()
        button.isEnabled = false
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        button.layer.borderColor = .
        return  button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }

    private func configureUI() {
        view.addSubviews([bookRank, bookTitle, bookAuthorPublisher, showLiked])
    }
}
