
import UIKit

extension UISwipeActionsConfiguration {

    static func deleteSwipe(
        _ handler: @escaping (@escaping (Bool) -> Void) -> Void
    ) -> UISwipeActionsConfiguration {
        let action = UIContextualAction(style: .normal, title: "삭제") { _, _, done in
            handler(done)
        }
        action.image = UIImage(systemName: "trash.fill")
        action.backgroundColor = .customAlert

        let config = UISwipeActionsConfiguration(actions: [action])
        config.performsFirstActionWithFullSwipe = true
        return config
    }
}
