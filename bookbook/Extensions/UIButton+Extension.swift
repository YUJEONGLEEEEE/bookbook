
import UIKit
import SnapKit

private struct ButtonOverlayKey {
    static var overlay = "overlay"
}

extension UIButton {
    
    func confirmButton(
        title: String,
        titleColor: UIColor,
        backColor: UIColor,
    ) {
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
        configureSelectableOverlay()
    }

    func topImageButton(
        image: UIImage?,
        title: String,
        cornerRadius: CGFloat = 10,
        imagePadding: CGFloat = 8,
        backgroundColor: UIColor = .customWh
    ) {
        var config = UIButton.Configuration.filled()
        config.image = image
        config.title = title
        config.imagePlacement = .top
        config.imagePadding = imagePadding
        config.baseBackgroundColor = backgroundColor
        configuration = config

        layer.cornerRadius = cornerRadius
        layer.shadowColor = UIColor.bk1.cgColor
        layer.shadowOpacity = 0.15
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 8
        clipsToBounds = false
        snp.makeConstraints { make in
            make.size.equalTo(170)
        }
    }

    private var overlayView: UIView? {
        get {
            return objc_getAssociatedObject(self, &ButtonOverlayKey.overlay) as? UIView
        }
        set {
            objc_setAssociatedObject(self, &ButtonOverlayKey.overlay, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    func configureSelectableOverlay() {
        if overlayView != nil { return }
        let overlay = UIView()
        overlay.backgroundColor = UIColor.customMain.withAlphaComponent(0.8)
        overlay.layer.cornerRadius = 8
        overlay.clipsToBounds = true
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
