//
//  BookmarkCollectionViewCell.swift
//  bookbook
//
//  Created by 이유정 on 9/16/25.
//

import UIKit
import SnapKit

class BookmarkCollectionViewCell: UICollectionViewCell {

    let bookImage: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        return image
    }()

    let bookTitle: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 17)
        label.textAlignment = .left
        label.textColor = .black
        label.numberOfLines = 0 // 추후 변경 여지 있음
        return label
    }()

    let authorLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.textAlignment = .left
        label.textColor = .gray
        label.numberOfLines = 0 // 추후 변경 여지 있음
        return label
    }()

    let bookmarkButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "bookmark"), for: .normal)
        button.contentMode = .scaleAspectFit
        button.tintColor = .white
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
        contentView.addSubviews([bookImage, bookTitle, authorLabel])
        bookImage.addSubview(bookmarkButton)

        bookImage.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview()
            make.height.equalTo(bookImage.snp.width).multipliedBy(4 / 3) // <- 3:4 비율 유지
        }
        bookTitle.snp.makeConstraints { make in
            make.top.equalTo(bookImage.snp.bottom).offset(10)
            make.horizontalEdges.equalToSuperview()
        }
        authorLabel.snp.makeConstraints { make in
            make.top.equalTo(bookTitle.snp.bottom).offset(8)
            make.horizontalEdges.equalToSuperview()
        }
    }

}
