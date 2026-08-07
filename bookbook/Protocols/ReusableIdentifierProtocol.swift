
import UIKit

protocol ReusableIdentifierProtocol {
    static var identifier: String { get }
}

extension ReusableIdentifierProtocol {
    static var identifier: String {
        String(describing: self)
    }
}

extension UITableViewCell: ReusableIdentifierProtocol {}
extension UITableViewHeaderFooterView: ReusableIdentifierProtocol {}
extension UICollectionReusableView: ReusableIdentifierProtocol {}
