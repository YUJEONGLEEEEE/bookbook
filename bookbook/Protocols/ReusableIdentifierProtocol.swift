//
//  ReusableIdentifierProtocol.swift
//  bookbook
//
//  Created by 이유정 on 9/16/25.
//

import UIKit

protocol ReusableIdentifierProtocol {
    static var identifier: String { get }
}

extension UIViewController: ReusableIdentifierProtocol {
    static var identifier: String {
        return String(describing: self)
    }
}

extension UICollectionViewCell: ReusableIdentifierProtocol {
    static var identifier: String {
        return String(describing: self)
    }
}

extension UITableViewCell: ReusableIdentifierProtocol {
    static var identifier: String {
        return String(describing: self)
    }
}
