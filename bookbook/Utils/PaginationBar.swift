
import UIKit

enum PaginationBar {

    static func render(
        stackView: UIStackView,
        previousButton: UIButton,
        nextButton: UIButton,
        pageButtons: inout [UIButton],
        currentPage: Int,
        totalPages: Int,
        maxPagesShown: Int,
        pageTarget: Any?,
        pageAction: Selector
    ) {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        pageButtons.removeAll()

        let canGoPrevious = currentPage > 1
        previousButton.isEnabled = canGoPrevious
        previousButton.setTitleColor(canGoPrevious ? .bk2 : .bk4, for: .normal)
        stackView.addArrangedSubview(previousButton)

        let startPage = max(1, currentPage - 4)
        let endPage = min(totalPages, startPage + maxPagesShown - 1)

        for page in startPage...endPage {
            let button = UIButton(type: .system)
            button.setTitle("\(page)", for: .normal)
            button.tag = page
            button.setTitleColor(page == currentPage ? .bk1 : .bk3, for: .normal)
            button.titleLabel?.font = page == currentPage
            ? UIFont.customFont(ofSize: 17, weight: .bold)
            : UIFont.customFont(ofSize: 17, weight: .medium)
            button.removeTarget(nil, action: nil, for: .touchUpInside)
            button.addTarget(pageTarget, action: pageAction, for: .touchUpInside)
            pageButtons.append(button)
            stackView.addArrangedSubview(button)
        }

        let canGoNext = currentPage < totalPages
        nextButton.isEnabled = canGoNext
        nextButton.setTitleColor(canGoNext ? .bk2 : .bk4, for: .normal)
        stackView.addArrangedSubview(nextButton)
    }
}
