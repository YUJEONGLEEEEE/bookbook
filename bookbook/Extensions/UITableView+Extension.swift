
import UIKit

extension UITableView {

    // MARK: - Register

    func register<T: UITableViewCell>(_ cellType: T.Type) {
        register(cellType, forCellReuseIdentifier: T.identifier)
    }

    func register<T: UITableViewHeaderFooterView>(_ viewType: T.Type) {
        register(viewType, forHeaderFooterViewReuseIdentifier: T.identifier)
    }

    // MARK: - Dequeue

    func dequeue<T: UITableViewCell>(_ cellType: T.Type, for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withIdentifier: T.identifier, for: indexPath) as? T else {
            fatalError("\(T.identifier) is not registered")
        }
        return cell
    }

    func dequeue<T: UITableViewHeaderFooterView>(_ viewType: T.Type) -> T {
        guard let view = dequeueReusableHeaderFooterView(withIdentifier: T.identifier) as? T else {
            fatalError("\(T.identifier) is not registered")
        }
        return view
    }
}
