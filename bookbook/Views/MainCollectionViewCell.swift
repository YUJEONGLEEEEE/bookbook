
import UIKit
import SnapKit

class MainCollectionViewCell: UICollectionViewCell {

    let bookStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 8
        view.alignment = .center
        view.distribution = .fill
        return view
    }()

    let bookImage: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
        image.backgroundColor = .bk5
        image.clipsToBounds = true
        return image
    }()

    let bookTitle: UILabel = {
        let label = UILabel()
        label.textColor = .bk1
        label.textAlignment = .left
        label.font = UIFont.customFont(ofSize: 18, weight: .medium)
        return label
    }()

    let bookAuthor: UILabel = {
        let label = UILabel()
        label.textColor = .bk3
        label.textAlignment = .left
        label.font = UIFont.customFont(ofSize: 16, weight: .regular)
        return label
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
        bookAuthor.text = nil
    }

    private func configureUI() {
        contentView.addSubview(bookStackView)
        bookStackView.alignment = .fill
        bookStackView.addArrangedSubviews([bookImage, bookTitle, bookAuthor])
        bookStackView.setCustomSpacing(12, after: bookImage)
        bookStackView.setCustomSpacing(4, after: bookTitle)
        bookStackView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview()
            make.bottom.lessThanOrEqualToSuperview()
        }
        bookImage.snp.makeConstraints { make in
            make.height.equalTo(186)
        }
        bookTitle.numberOfLines = 1
        bookAuthor.numberOfLines = 1
    }
}
