//
//  LikedCollectionViewCell.swift
//  bookbook
//
//  Created by 이유정 on 10/8/25.
//

import UIKit
import SnapKit

class LikedCollectionViewCell: UICollectionViewCell {

    let bookStackView: UIStackView = {
        let view = UIStackView()
        view.bookStackView()
        return view
    }()

    let bookImage: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        return image
    }()

    let bookTitle: UILabel = {
        let label = UILabel()
        label.standardLabel()
        label.numberOfLines = 1
        return label
    }()

    let bookAuthor: UILabel = {
        let label = UILabel()
        label.subLabel()
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
        contentView.addSubview(bookStackView)
        bookStackView.addArrangedSubviews([bookImage, bookTitle, bookAuthor])
        bookStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
