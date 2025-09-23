//
//  RecentSearchedCollectionViewCell.swift
//  bookbook
//
//  Created by 이유정 on 9/23/25.
//

import UIKit
import SnapKit

class RecentSearchedCollectionViewCell: UICollectionViewCell {

    private let stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 10
        view.distribution = .fill
        view.alignment = .center
        return view
    }()

    let wordLabel: UILabel = {
        let label = UILabel()
        return label
    }()

    let deleteButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .black
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
        contentView.layer.cornerRadius = 11
        contentView.addSubview(stackView)
        stackView.addArrangedSubviews([wordLabel, deleteButton])
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(3)
        }
    }

}
