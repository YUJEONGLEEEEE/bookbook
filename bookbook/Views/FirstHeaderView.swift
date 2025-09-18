//
//  FirstHeaderView.swift
//  bookbook
//
//  Created by 이유정 on 9/19/25.
//

import UIKit
import SnapKit

class FirstHeaderView: UICollectionReusableView {

    private let firstSectionTitle: UILabel = {
        let label = UILabel()
        label.text = "선호장르책리스트"
        label.textAlignment = .left
        return label
    }()

    private let sectionButton: UIButton = {
        let button = UIButton()
        button.setTitle("더보기 ", for: .normal)
        button.setImage(UIImage(systemName: "chevron.forward.2"), for: .normal)
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
        self.addSubviews([firstSectionTitle, sectionButton])
        firstSectionTitle.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(16)
        }
        sectionButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(16)
        }
    }

}
