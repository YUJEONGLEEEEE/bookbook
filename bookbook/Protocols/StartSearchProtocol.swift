
import Foundation

protocol StartSearchProtocol: AnyObject {
    func startSearchView(_ view: StartSearchView, didSelectQuery query: String)
    func didDeleteRecentSearch(at index: Int)
}
