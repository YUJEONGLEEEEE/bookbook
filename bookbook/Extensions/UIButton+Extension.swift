//
//  UIButton+Extension.swift
//  bookbook
//
//  Created by 이유정 on 10/1/25.
//

import UIKit
import SnapKit

extension UIButton {
    
    func configureGrayButton() {
        setTitleColor(.white, for: .normal)
        backgroundColor = .gray
        layer.cornerRadius = 10
        clipsToBounds = true
        titleLabel?.textAlignment = .center
        titleLabel?.font = .systemFont(ofSize: 15)
        snp.makeConstraints { make in
            make.height.equalTo(44)
        }
    }
}
