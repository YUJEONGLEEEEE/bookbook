
import UIKit

enum PaginationBar {

    static func render(
        stackView: UIStackView,
        previousBlockButton: UIButton,
        previousButton: UIButton,
        nextButton: UIButton,
        nextBlockButton: UIButton,
        pageButtons: inout [UIButton],
        currentPage: Int,
        totalPages: Int,
        maxPagesShown: Int,
        availableWidth: CGFloat,
        pageTarget: Any?,
        pageAction: Selector
    ) {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        pageButtons.removeAll()

        var startPage = max(1, currentPage - maxPagesShown / 2)
        let endPage = min(totalPages, startPage + maxPagesShown - 1)
        startPage = max(1, endPage - maxPagesShown + 1)

        let canGoPreviousBlock = currentPage > 1
        previousBlockButton.isEnabled = canGoPreviousBlock
        previousBlockButton.setPaginationArrow(double: true, pointsLeft: true, active: canGoPreviousBlock)
        stackView.addArrangedSubview(previousBlockButton)

        let canGoPrevious = currentPage > 1
        previousButton.isEnabled = canGoPrevious
        previousButton.setPaginationArrow(double: false, pointsLeft: true, active: canGoPrevious)
        stackView.addArrangedSubview(previousButton)

        let numberCount = endPage - startPage + 1
        let arrowWidth: CGFloat = 24
        let widest = String(endPage) as NSString
        let widestWidth = widest.size(withAttributes: [.font: UIFont.customFont(ofSize: 17, weight: .bold)]).width
        let usableWidth = availableWidth - 48

        func rowWidth(fontSize: CGFloat, spacing: CGFloat) -> CGFloat {
            let numbers = widestWidth * (fontSize / 17) * CGFloat(numberCount)
            let arrows = arrowWidth * 4
            let gaps = spacing * CGFloat(numberCount + 4 - 1)
            return numbers + arrows + gaps
        }

        let defaultSpacing: CGFloat = 20
        var spacing = defaultSpacing
        var fontSize: CGFloat = 17
        if rowWidth(fontSize: 17, spacing: defaultSpacing) > usableWidth {
            spacing = 8
            if rowWidth(fontSize: 17, spacing: spacing) > usableWidth {
                let widthForNumbers = usableWidth - arrowWidth * 4 - spacing * CGFloat(numberCount + 4 - 1)
                fontSize = max(11, floor(17 * widthForNumbers / (widestWidth * CGFloat(numberCount))))
            }
        }
        stackView.spacing = spacing

        let pageFontBold = UIFont.customFont(ofSize: fontSize, weight: .bold)
        let pageFontMedium = UIFont.customFont(ofSize: fontSize, weight: .medium)

        for page in startPage...endPage {
            let button = UIButton(type: .system)
            button.setTitle("\(page)", for: .normal)
            button.tag = page
            button.setTitleColor(page == currentPage ? .customMain : .bk3, for: .normal)
            button.titleLabel?.font = page == currentPage ? pageFontBold : pageFontMedium
            button.removeTarget(nil, action: nil, for: .touchUpInside)
            button.addTarget(pageTarget, action: pageAction, for: .touchUpInside)
            pageButtons.append(button)
            stackView.addArrangedSubview(button)
        }

        let canGoNext = currentPage < totalPages
        nextButton.isEnabled = canGoNext
        nextButton.setPaginationArrow(double: false, pointsLeft: false, active: canGoNext)
        stackView.addArrangedSubview(nextButton)

        let canGoNextBlock = currentPage < totalPages
        nextBlockButton.isEnabled = canGoNextBlock
        nextBlockButton.setPaginationArrow(double: true, pointsLeft: false, active: canGoNextBlock)
        stackView.addArrangedSubview(nextBlockButton)
    }
}
