
import UIKit
import SnapKit

final class OnboardingViewController: UIViewController {

    private let imageNames = ["tutorial_01", "tutorial_02"]
    private var currentIndex = 0

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
        configureUI()
        setupGesture()
        showImage()
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
            print("gotonextpage")
            showImage()
        } else {
            print("LastPage")
            finishTutorial()
        }
    }

    private func showImage() {
        tutorialImageView.image = UIImage(named: imageNames[currentIndex])
    }

    private func finishTutorial() {
        UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")

        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return
        }

        window.rootViewController = MainViewController()
        window.makeKeyAndVisible()
    }
}
