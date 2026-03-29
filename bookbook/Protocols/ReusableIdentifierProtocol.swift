
import UIKit

protocol ReusableIdentifierProtocol {
    static var identifier: String { get }
}

extension UIViewController: ReusableIdentifierProtocol {
    static var identifier: String {
        return String(describing: self)
    }
}

extension UIView: ReusableIdentifierProtocol {
    static var identifier: String {
        return String(describing: self)
    }
}
