
import CoreData
import Foundation

protocol SecondHeaderProtocol: AnyObject {
    func secondHeaderView(_ headerView: SecondHeaderView, didSelect book: ISBNConvertible)
}
