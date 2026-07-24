
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

        let startPage = ((currentPage - 1) / maxPagesShown) * maxPagesShown + 1
        let endPage = min(totalPages, startPage + maxPagesShown - 1)

        let canGoPreviousBlock = startPage > 1
        previousBlockButton.isEnabled = canGoPreviousBlock
        previousBlockButton.setTitleColor(canGoPreviousBlock ? .bk2 : .bk4, for: .normal)
        stackView.addArrangedSubview(previousBlockButton)

        let canGoPrevious = currentPage > 1
        previousButton.isEnabled = canGoPrevious
        previousButton.setTitleColor(canGoPrevious ? .bk2 : .bk4, for: .normal)
        stackView.addArrangedSubview(previousButton)

        let cellCount = (endPage - startPage + 1) + 4
        let widest = String(endPage) as NSString
        let widestWidth = widest.size(withAttributes: [.font: UIFont.customFont(ofSize: 17, weight: .bold)]).width
        let usableWidth = availableWidth - 48

        func rowWidth(fontSize: CGFloat, spacing: CGFloat) -> CGFloat {
            widestWidth * (fontSize / 17) * CGFloat(cellCount) + spacing * CGFloat(cellCount - 1)
        }

        let defaultSpacing: CGFloat = 20
        var spacing = defaultSpacing
        var fontSize: CGFloat = 17
        if rowWidth(fontSize: 17, spacing: defaultSpacing) > usableWidth {
            spacing = 8
            if rowWidth(fontSize: 17, spacing: spacing) > usableWidth {
                let widthForCells = usableWidth - spacing * CGFloat(cellCount - 1)
                fontSize = max(11, floor(17 * widthForCells / (widestWidth * CGFloat(cellCount))))
            }
        }
        stackView.spacing = spacing

        let pageFontBold = UIFont.customFont(ofSize: fontSize, weight: .bold)
        let pageFontMedium = UIFont.customFont(ofSize: fontSize, weight: .medium)
        let arrowFont = UIFont.customFont(ofSize: fontSize, weight: .semibold)
        previousBlockButton.titleLabel?.font = arrowFont
        previousButton.titleLabel?.font = arrowFont
        nextButton.titleLabel?.font = arrowFont
        nextBlockButton.titleLabel?.font = arrowFont

        for page in startPage...endPage {
            let button = UIButton(type: .system)
            button.setTitle("\(page)", for: .normal)
            button.tag = page
            button.setTitleColor(page == currentPage ? .bk1 : .bk3, for: .normal)
            button.titleLabel?.font = page == currentPage ? pageFontBold : pageFontMedium
            button.removeTarget(nil, action: nil, for: .touchUpInside)
            button.addTarget(pageTarget, action: pageAction, for: .touchUpInside)
            pageButtons.append(button)
            stackView.addArrangedSubview(button)
        }

        let canGoNext = currentPage < totalPages
        nextButton.isEnabled = canGoNext
        nextButton.setTitleColor(canGoNext ? .bk2 : .bk4, for: .normal)
        stackView.addArrangedSubview(nextButton)

        let canGoNextBlock = endPage < totalPages
        nextBlockButton.isEnabled = canGoNextBlock
        nextBlockButton.setTitleColor(canGoNextBlock ? .bk2 : .bk4, for: .normal)
        stackView.addArrangedSubview(nextBlockButton)
    }
}
