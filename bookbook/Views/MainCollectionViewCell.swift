//
//  MainCollectionViewCell.swift
//  bookbook
//
//  Created by 이유정 on 9/18/25.
//

import UIKit
import SnapKit

class MainCollectionViewCell: UICollectionViewCell {

    let bookStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 5
        view.alignment = .center
        view.distribution = .fill
        return view
    }()

    let bookImage: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        image.layer.cornerRadius = 8
        image.clipsToBounds = true
        return image
    }()

    let bookTitle: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 17)
        return label
    }()

    let bookAuthor: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 13)
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureUI() {
        contentView.addSubview(bookStackView)
        bookStackView.addArrangedSubviews([bookImage, bookTitle, bookAuthor])
        bookImage.snp.makeConstraints { make in
            make.height.equalTo(60)
            make.width.equalTo(40)
        }
    }
}
