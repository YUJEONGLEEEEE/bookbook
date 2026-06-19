
import UIKit
import SnapKit

private enum ButtonOverlayKey {
    // associated object 키로 쓸 안정적인 고유 포인터 (앱 생애주기 동안 유지)
    // String 주소를 키로 쓰면 "UnsafeRawPointer ... exposes internal representation" 경고가 나므로 raw 포인터를 사용한다.
    static let overlay = UnsafeMutableRawPointer.allocate(byteCount: 1, alignment: 1)
}

extension UIButton {

    func confirmButton(
        title: String,
        titleColor: UIColor,
        backColor: UIColor,
    ) {
        setTitle(title, for: .normal)
        setTitleColor(titleColor, for: .normal)
        backgroundColor = backColor
        layer.cornerRadius = 8
        clipsToBounds = true
        titleLabel?.textAlignment = .center
        titleLabel?.font = UIFont.customFont(ofSize: 17, weight: .medium)
        isEnabled = false
        snp.makeConstraints { make in
            make.height.equalTo(56)
        }
    }

    func showLikedCounts(count: Int){
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "heart.fill")
        config.imagePadding = 4
        config.imagePlacement = .leading
        config.baseForegroundColor = .sub01
        config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
        config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 13)
        config.background.backgroundColor = .customWh
        config.background.cornerRadius = 8
        config.background.strokeColor = .bk6
        config.background.strokeWidth = 1
        var title = AttributedString("\(count)")
        title.font = UIFont.customFont(ofSize: 13, weight: .medium)
        config.attributedTitle = title
        configuration = config
        isUserInteractionEnabled = false
    }

    func showBookmarked() {
        var config = UIButton.Configuration.plain()
        config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 14, bottom: 8, trailing: 14)
        config.background.cornerRadius = 8
        config.background.backgroundColor = .customWh
        config.background.strokeColor = .customMain
        config.background.strokeWidth = 1
        var title = AttributedString("담았어요")
        title.font = UIFont.customFont(ofSize: 13, weight: .medium)
        title.foregroundColor = .customMain
        config.attributedTitle = title
        config.baseForegroundColor = .customMain
        configuration = config
        isUserInteractionEnabled = false
        isHidden = true
    }

    // MARK: - prefernce, age, gender check viewcontroller

    func imageButton(
        title: String,
        image: UIImage?,
        size: Int
    ) {
        setBackgroundImage(image, for: .normal)
        setTitle(title, for: .normal)
        setTitleColor(.customWh, for: .normal)
        titleLabel?.font = UIFont.customFont(ofSize: 17, weight: .medium)
        titleLabel?.textAlignment = .center
        layer.cornerRadius = 8
        clipsToBounds = true
        snp.makeConstraints { make in
            make.size.equalTo(size)
        }
        configureSelectableOverlay(with: image)
    }

    private var overlayView: UIView? {
        get {
            return objc_getAssociatedObject(self, ButtonOverlayKey.overlay) as? UIView
        }
        set {
            objc_setAssociatedObject(self, ButtonOverlayKey.overlay, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    func configureSelectableOverlay(with image: UIImage?) {
        if overlayView != nil { return }
        // 단색 사각형 대신 이미지와 동일한 형태(둥근 모서리 포함)로 덮이도록 템플릿 이미지 사용
        let overlay = UIImageView(image: image?.withRenderingMode(.alwaysTemplate))
        overlay.contentMode = .scaleToFill
        overlay.tintColor = UIColor.customMain.withAlphaComponent(0.8)
        overlay.isUserInteractionEnabled = false
        overlay.alpha = 0

        addSubview(overlay)
        overlay.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        overlayView = overlay
    }
    func setSelectedOverlay(_ selected: Bool) {
        overlayView?.alpha = selected ? 1.0 : 0.0
    }
}
