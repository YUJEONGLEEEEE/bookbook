//
//  BookmarkTableViewCell.swift
//  bookbook
//
//  Created by 이유정 on 9/16/25.
//

import UIKit
import SnapKit

class BookmarkTableViewCell: UITableViewCell {

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

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureUI() {
        contentView.addSubviews([bookImage, bookTitle, authorLabel, bookmarkButton])
    }

}
