
import UIKit

extension UICollectionView {

    static let paginationFooter = "PaginationFooter"

    // MARK: - Register

    func register<T: UICollectionViewCell>(_ cellType: T.Type) {
        register(cellType, forCellWithReuseIdentifier: T.identifier)
    }

    func register<T: UICollectionReusableView>(_ viewType: T.Type, ofKind kind: String) {
        register(viewType, forSupplementaryViewOfKind: kind, withReuseIdentifier: T.identifier)
    }

    // MARK: - Dequeue

    func dequeue<T: UICollectionViewCell>(_ cellType: T.Type, for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withReuseIdentifier: T.identifier, for: indexPath) as? T else {
            fatalError("\(T.identifier) is not registered")
        }
        return cell
    }

    func dequeue<T: UICollectionReusableView>(_ viewType: T.Type, ofKind kind: String, for indexPath: IndexPath) -> T {
        guard let view = dequeueReusableSupplementaryView(
            ofKind: kind, withReuseIdentifier: T.identifier, for: indexPath
        ) as? T else {
            fatalError("\(T.identifier) is not registered")
        }
        return view
    }
}
