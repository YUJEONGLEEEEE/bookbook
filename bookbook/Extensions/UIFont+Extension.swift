
import UIKit

extension UIFont {
    static func appFont(ofSize size: CGFloat, weight: UIFont.Weight = .regular) -> UIFont {
        let fontName: String

        switch weight {
        case .bold:
            fontName = "AppleSDGothicNeo-Bolď"
        case .semibold:
            fontName = "AppleSDGothicNeo-SemiBold"
        case .medium:
            fontName = "AppleSDGothicNeo-Medium"
        case .light:
            fontName = "AppleSDGothicNeo-Light"
        case .thin:
            fontName = "AppleSDGothicNeo-Thin"
        default:
            fontName = "AppleSDGothicNeo-Regular"
        }
        return UIFont(name: fontName, size: size) ?? .systemFont(ofSize: size, weight: weight)
    }
}
