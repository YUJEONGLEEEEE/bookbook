
import UIKit
import SnapKit
import Kingfisher

class BookmarkCollectionViewCell: UICollectionViewCell {

    let bookImage: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        image.backgroundColor = .bk6
        return image
    }()

    // 커버 모서리에 붙으므로 안쪽(왼쪽 아래) 꼭지점만 둥글게 처리한다.
    private let bookmarkBadge: UIView = {
        let view = UIView()
        view.backgroundColor = .customMain
        view.layer.cornerRadius = 8
        view.layer.maskedCorners = [.layerMinXMaxYCorner]   // 왼쪽 아래만
        view.clipsToBounds = true
        return view
    }()

    private let bookmarkSymbol: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "bookshelf_white")?.withRenderingMode(.alwaysTemplate)
        view.tintColor = .customWh
        view.contentMode = .scaleAspectFit
        return view
    }()

    let bookTitle: UILabel = {
        let label = UILabel()
        label.font = UIFont.customFont(ofSize: 18, weight: .medium)
        label.textAlignment = .left
        label.textColor = .bk1
        label.numberOfLines = 2
        return label
    }()

    let authorLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.customFont(ofSize: 16, weight: .regular)
        label.textAlignment = .left
        label.textColor = .bk3
        label.numberOfLines = 1
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
        authorLabel.text = nil
    }

    private func configureUI() {
        contentView.addSubviews([bookImage, bookTitle, authorLabel])
        bookImage.addSubview(bookmarkBadge)
        bookmarkBadge.addSubview(bookmarkSymbol)

        bookImage.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview()
            make.height.equalTo(239)
        }
        bookmarkBadge.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview()
            make.size.equalTo(48)
        }
        bookmarkSymbol.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(24)
        }
        bookTitle.snp.makeConstraints { make in
            make.top.equalTo(bookImage.snp.bottom).offset(12)
            make.horizontalEdges.equalToSuperview()
        }
        authorLabel.snp.makeConstraints { make in
            make.top.equalTo(bookTitle.snp.bottom).offset(4)
            make.horizontalEdges.bottom.equalToSuperview()
        }
    }
}
