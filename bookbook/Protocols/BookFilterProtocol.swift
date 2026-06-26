
import Foundation

protocol BookFilterProtocol: AnyObject {
    func bookFilterView(_ view: BookFilterView, didSelectFilter filter: BookFilter)
    func bookFilterViewDidClearSelection(_ view: BookFilterView)
}

extension BookFilterProtocol {
    func bookFilterViewDidClearSelection(_ view: BookFilterView) {}
}
