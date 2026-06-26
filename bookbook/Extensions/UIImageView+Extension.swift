
import UIKit
import Kingfisher

private let coverPlaceholderImage: UIImage? = {
    guard let base = UIImage(named: "placeholder") else { return nil }
    let size = CGSize(width: 72, height: 72)
    let renderer = UIGraphicsImageRenderer(size: size)
    return renderer.image { _ in
        base.draw(in: CGRect(origin: .zero, size: size))
    }
}()

extension UIImageView {
    func setBookCover(_ urlString: String?, coverMode: UIView.ContentMode = .scaleAspectFill) {
        backgroundColor = .bk5
        let s = urlString?.trimmingCharacters(in: .whitespaces) ?? ""

        if s.isEmpty || s.lowercased().contains("noimg") || URL(string: s) == nil {
            kf.cancelDownloadTask()
            contentMode = .center
            image = coverPlaceholderImage
            return
        }
        contentMode = coverMode
        kf.setImage(with: URL(string: s)!)
    }
}
