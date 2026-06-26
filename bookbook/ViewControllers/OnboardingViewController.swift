
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
        guard !isFinishing else { return }
        isFinishing = true
        UserSession.markTutorialSeen()
        MainTabBarController.setAsRoot()
    }
}
