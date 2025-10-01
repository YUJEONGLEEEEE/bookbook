//
//  UILabel+Extension.swift
//  bookbook
//
//  Created by 이유정 on 10/1/25.
//

import UIKit

extension UILabel {
    
    func configureTitleLabel() {
        font = .boldSystemFont(ofSize: 34)
        textColor = .black
        textAlignment = .left
    }

    func configureTextLabel() {
        font = .systemFont(ofSize: 17)
        textColor = .black
        textAlignment = .left
    }

    func configureSubLabel() {
        font = .systemFont(ofSize: 15)
        textColor = .black
        textAlignment = .left
    }
}
