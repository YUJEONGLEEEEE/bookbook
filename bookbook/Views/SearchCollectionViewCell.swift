
import UIKit
import Kingfisher
import SnapKit

class SearchCollectionViewCell: UICollectionViewCell {

    let bookImage: UIImageView = {
        let image = UIImageView()
        image.backgroundColor = .bk5
        image.contentMode = .scaleAspectFit
        image.clipsToBounds = true
        return image
    }()

    let mainStack: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.distribution = .fill
        view.alignment = .leading
        return view
    }()

    let bookTitle: UILabel = {
        let label = UILabel()
        label.font = UIFont.customFont(ofSize: 17, weight: .medium)
        label.textAlignment = .left
        label.numberOfLines = 1
        label.textColor = .bk1
        return label
    }()

    let subLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.customFont(ofSize: 14, weight: .medium)
        label.textAlignment = .left
        label.numberOfLines = 1
        label.textColor = .bk2
        return label
    }()

    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.customFont(ofSize: 14, weight: .medium)
        label.numberOfLines = 2
        label.textAlignment = .left
        label.textColor = .bk3
        return label
    }()

    private let buttonStack: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 8
        view.alignment = .center
        view.distribution = .fill
        return view
    }()

    let showLiked: UIButton = {
        let button = UIButton()
        button.showLikedCounts(count: 0)
        return button
    }()

    let bookmarked: UIButton = {
        let button = UIButton()
        button.showBookmarked()
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        bookImage.kf.cancelDownloadTask()
        bookImage.image = nil
        bookTitle.text = nil
        subLabel.text = nil
        descriptionLabel.text = nil
        bookmarked.isHidden = true
        showLiked.showLikedCounts(count: 0)
    }

    private func configureUI() {
        contentView.backgroundColor = .clear
        contentView.addSubviews([bookImage, mainStack])
        mainStack.addArrangedSubviews([bookTitle, subLabel, descriptionLabel, buttonStack])
        buttonStack.addArrangedSubviews([showLiked, bookmarked])

        bookImage.snp.makeConstraints { make in
            make.width.equalTo(86)
            make.height.equalTo(123)
            make.leading.verticalEdges.equalToSuperview()
        }
        mainStack.snp.makeConstraints { make in
            make.leading.equalTo(bookImage.snp.trailing).offset(14)
            make.verticalEdges.trailing.equalToSuperview()
        }
        subLabel.snp.makeConstraints { make in
            make.top.equalTo(bookTitle.snp.bottom).offset(4)
        }
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(subLabel.snp.bottom).offset(4)
        }
        buttonStack.snp.makeConstraints { make in
            make.height.equalTo(32)
            make.top.equalTo(descriptionLabel.snp.bottom).offset(8)
        }
    }
}
