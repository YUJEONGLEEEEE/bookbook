
import UIKit
import SnapKit

final class OnboardingViewController: UIViewController {

    private let imageNames = ["tutorial_01", "tutorial_02"]
    private var currentIndex = 0
    private var isFinishing = false

    private let tutorialImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.clipsToBounds = true
        view.isUserInteractionEnabled = true
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .customWh
        // 모든 설정이 끝난 뒤 보는 화면이므로 뒤로가기를 막는다. (재설정은 설정 화면에서만)
        navigationItem.hidesBackButton = true
        configureUI()
        setupGesture()
        showImage()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }

    private func configureUI() {
        view.addSubview(tutorialImageView)
        tutorialImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func setupGesture() {
        let tap = UITapGestureRecognizer(
            target: self, action: #selector(tapImage)
        )
        tutorialImageView.addGestureRecognizer(tap)
    }
    @objc func tapImage() {
        currentIndex += 1
        if currentIndex < imageNames.count {
            showImage()
        } else {
            finishTutorial()
        }
    }

    private func showImage() {
        tutorialImageView.image = UIImage(named: imageNames[currentIndex])
    }

    private func finishTutorial() {
        // 마지막 페이지 더블탭으로 setAsRoot가 중복 실행되는 것 방지
        guard !isFinishing else { return }
        isFinishing = true
        // 현재 계정이 튜토리얼을 봤다고 기록 → 재가입(새 UUID) 전까지 다시 노출되지 않는다.
        UserSession.markTutorialSeen()
        MainTabBarController.setAsRoot()
    }
}
