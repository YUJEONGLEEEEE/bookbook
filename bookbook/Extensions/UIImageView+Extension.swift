
import UIKit
import Kingfisher

// placeholder는 회색 박스 안에 72x72 아이콘 중앙 배치 (피그마). 한 번만 만들어 재사용한다.
private let coverPlaceholderImage: UIImage? = {
    guard let base = UIImage(named: "placeholder") else { return nil }
    let size = CGSize(width: 72, height: 72)
    let renderer = UIGraphicsImageRenderer(size: size)
    return renderer.image { _ in
        base.draw(in: CGRect(origin: .zero, size: size))
    }
}()

extension UIImageView {
    /// 책 표지 로드. URL이 비어있거나 알라딘 기본 "No Image"(noimg)면
    /// 회색 배경 + 72x72 중앙 placeholder로 표시한다. (피그마)
    /// - coverMode: 실제 표지일 때 사용할 contentMode (셀마다 다름)
    func setBookCover(_ urlString: String?, coverMode: UIView.ContentMode = .scaleAspectFill) {
        backgroundColor = .bk5
        let s = urlString?.trimmingCharacters(in: .whitespaces) ?? ""

        if s.isEmpty || s.lowercased().contains("noimg") || URL(string: s) == nil {
            kf.cancelDownloadTask()
            contentMode = .center          // 72x72 아이콘을 키우지 않고 중앙 배치
            image = coverPlaceholderImage
            return
        }
        contentMode = coverMode
        kf.setImage(with: URL(string: s)!)
    }
}
