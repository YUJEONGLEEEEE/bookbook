
import UIKit
import SnapKit

class QuoteCardView: UIView {

    private let backgroundImage: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
        return image
    }()

    private let leftDoubleQuotes: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(systemName: "quote.opening")
        view.contentMode = .scaleAspectFit
        view.tintColor = .black
        return view
    }()

    private let quoteLabel: UILabel = {
        let label = UILabel()
        label.textColor = .customWh
        label.font = .systemFont(ofSize: 17)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private let rightDoubleQuotes: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(systemName: "quote.closing")
        view.contentMode = .scaleAspectFit
        view.tintColor = .black
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureUI() {
        addSubview(backgroundImage)
        backgroundImage.addSubviews([leftDoubleQuotes, quoteLabel, rightDoubleQuotes])
    }

}
