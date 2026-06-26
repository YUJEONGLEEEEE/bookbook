
import UIKit
import SnapKit

final class AuthNavigationController: BaseNavigationController {

    private let backgroundImage: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.image = UIImage(named: "backgroundimage")
        view.clipsToBounds = true
        view.alpha = 0.4
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        view.insertSubview(backgroundImage, at: 0)
        backgroundImage.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
