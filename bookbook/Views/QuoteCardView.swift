
import UIKit
import SnapKit

class QuoteCardView: UIView {

    struct Quote {
        let image: String
        let title: String
        let author: String
    }

    private let quotes: [Quote] = [
        Quote(image: "quote01", title: "닥터 지바고", author: "보리스 파스테르나크"),
        Quote(image: "quote02", title: "체리토마토파이", author: "베로니크 드 뷔르"),
        Quote(image: "quote03", title: "소원을 이루어주는 섬", author: "유영광"),
        Quote(image: "quote04", title: "엄마를 부탁해", author: "신경숙"),
        Quote(image: "quote05", title: "긴긴밤", author: "루리"),
        Quote(image: "quote06", title: "우리가 사랑한 단어들", author: "신효원"),
        Quote(image: "quote07", title: "기분을 말해 봐", author: "앤서니 브라운"),
        Quote(image: "quote08", title: "안네의 일기", author: "안네 프랑크"),
        Quote(image: "quote09", title: "첫사랑", author: "김소월"),
        Quote(image: "quote10", title: "어쩌면 괜찮은 사람", author: "김혜진")
    ]

    private var shuffledQuotes: [Quote] = []
    private var lastImageName: String?

    private(set) var currentQuote: Quote?

    private let quoteCards: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        image.clipsToBounds = true
        return image
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
        showRandomImage()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func showRandomImage() {
        shuffledQuotes = quotes.shuffled()

        if let last = lastImageName,
           shuffledQuotes.first?.image == last,
           shuffledQuotes.count > 1 {
            shuffledQuotes.swapAt(0, 1)
        }

        let quote = shuffledQuotes[0]
        quoteCards.image = UIImage(named: quote.image)
        lastImageName = quote.image
        currentQuote = quote
    }

    private func configureUI() {
        addSubview(quoteCards)
        quoteCards.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
