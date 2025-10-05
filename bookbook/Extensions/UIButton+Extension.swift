//
//  UIButton+Extension.swift
//  bookbook
//
//  Created by 이유정 on 10/1/25.
//

import UIKit
import SnapKit

extension UIButton {
    
    func grayButton() {
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

    func imageButton(
        image: UIImage?,
        title: String,
        cornerRadius: CGFloat = 10,
        imagePadding: CGFloat = 8,
        backgroundColor: UIColor = .white
    ) {
        var config = UIButton.Configuration.filled()
        config.image = image
        config.title = title
        config.imagePlacement = .top
        config.imagePadding = imagePadding
        config.baseBackgroundColor = backgroundColor
        configuration = config

        layer.cornerRadius = cornerRadius
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.15
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 8
        clipsToBounds = false
        snp.makeConstraints { make in
            make.size.equalTo(170)
        }
    }
}
