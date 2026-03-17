
import UIKit
import SnapKit

class LevelEventViewController: UIViewController {

    private let backgroundImage: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.image = UIImage(named: "book_backgroundimage")
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }

    private func configureUI() {
        view.addSubview(backgroundImage)
        backgroundImage.addSubviews(<#T##views: [UIView]##[UIView]#>)
        backgroundImage.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
}
