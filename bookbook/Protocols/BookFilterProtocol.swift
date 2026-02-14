
import Foundation

protocol BookFilterProtocol: AnyObject {
    func bookFilterView(_ view: BookFilterView, didSelectFilter filter: BookFilter)
}
