
import UIKit
import SnapKit

class MyInfoViewController: UIViewController {

    private let nicknameLabel: UILabel = {
        let label = UILabel()
        label.text = "닉네임"
        return label
    }()

    private let nicknameTextField: UITextField = {
        let field = UITextField()
        return field
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureUI()
    }

    private func configureUI() {

    }
}
