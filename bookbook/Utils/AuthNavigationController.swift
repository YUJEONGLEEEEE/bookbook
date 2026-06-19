
import UIKit
import SnapKit

// 로그인/회원가입 공유 배경 고정용 네비게이션
// 배경을 네비게이션 뒤에 깔아두어, 화면전환 시 배경은 고정되고 콘텐츠만 슬라이드됨
final class AuthNavigationController: BaseNavigationController {

    private let backgroundImage: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.image = UIImage(named: "backgroundimage")
        view.clipsToBounds = true
        view.alpha = 0.4   // 검정 배경 위 40% → 어두운 톤
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        // 자식 화면들보다 뒤(맨 아래)에 고정 배경 삽입
        view.insertSubview(backgroundImage, at: 0)
        backgroundImage.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
