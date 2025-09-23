//
//  BookFilterCollectionViewCell.swift
//  bookbook
//
//  Created by 이유정 on 9/16/25.
//

import UIKit
import SnapKit

class BookFilterCollectionViewCell: UICollectionViewCell {

    let filterTitle: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 14)
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureFilter()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureFilter() {
        contentView.layer.cornerRadius = 11
        contentView.addSubview(filterTitle)
        filterTitle.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(3)
        }
    }

}
