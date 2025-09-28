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
        return image
    }()

    let bookTitle: UILabel = {
        let label = UILabel()
        return label
    }()

    let authorLabel: UILabel = {
        let label = UILabel()
        return label
    }()

    let bookmarkButton: UIButton = {
        let button = UIButton()
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
        contentView.addSubviews([bookImage, bookTitle, authorLabel, bookmarkButton])
    }

}
