
import UIKit
import SnapKit

final class AppVersionViewController: UIViewController {

    private let logoImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "appicon")
        view.contentMode = .scaleAspectFit
        view.clipsToBounds = true
        return view
    }()

    private let versionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.customFont(ofSize: 15, weight: .medium)
        label.textColor = .bk3
        label.textAlignment = .center
        label.text = "현재 버전 1.0.1"
        return label
    }()

    private let messageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.customFont(ofSize: 17, weight: .medium)
        label.textColor = .bk1
        label.textAlignment = .center
        label.text = "최신 버전을 사용중입니다."
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "앱 버전"
        view.backgroundColor = .customWh
        configureUI()
    }

    private func configureUI() {
        view.addSubviews([logoImageView, versionLabel, messageLabel])
        logoImageView.snp.makeConstraints { make in
            make.size.equalTo(100)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(205)
            make.centerX.equalTo(view.safeAreaLayoutGuide)
        }
        versionLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(logoImageView.snp.bottom).offset(68)
        }
        messageLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(versionLabel.snp.bottom).offset(35)
        }
    }
}
