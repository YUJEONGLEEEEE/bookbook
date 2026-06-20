
import Foundation

protocol BookFilterProtocol: AnyObject {
    func bookFilterView(_ view: BookFilterView, didSelectFilter filter: BookFilter)
    // 선택된 칩을 다시 탭해 해제(= 전체)했을 때. 기본 구현은 무시.
    func bookFilterViewDidClearSelection(_ view: BookFilterView)
}

extension BookFilterProtocol {
    func bookFilterViewDidClearSelection(_ view: BookFilterView) {}
}
