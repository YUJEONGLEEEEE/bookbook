
import UIKit
import SnapKit

class QuoteCardView: UIView {

    private var shuffledImages: [String] = []
    private var currentIndex: Int = 0

    private let images = (1...10).map { String(format: "quote%02d", $0)}

    private let quoteCards: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        image.clipsToBounds = true
        return image
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func resetShuffledImages() {
        shuffledImages = images.shuffled()
        if let lastImage = quoteCards.image?.accessibilityIdentifier,
           shuffledImages.first == lastImage {
            shuffledImages.swapAt(0, 1)
        }
        currentIndex = 0
    }

    func showNextImage() {
        if currentIndex >= shuffledImages.count {
            resetShuffledImages()
        }
        let imageName = shuffledImages[currentIndex]
        currentIndex += 1
        let image = UIImage(named: imageName)
        image.accessibilityIdentifier = imageName
        quoteCards.image = image
    }

    private func configureUI() {
        addSubview(quoteCards)
        quoteCards.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
