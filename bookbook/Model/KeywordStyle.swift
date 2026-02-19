// popularSearchedCollectionViewCell

import UIKit

enum KeywordStyle {
    case outlined
    case filled
    case muted

    var borderColor: UIColor {
        switch self {
        case .outlined, .filled: return .sub01
        case .muted: return .bk6
        }
    }

    var textColor: UIColor {
        switch self {
        case .outlined, .muted: return .sub01
        case .filled: return .customWh
        }
    }

    var backgroundColor: UIColor {
        switch self {
        case .outlined: return .clear
        case .filled: return .sub01
        case .muted: return .bk6
        }
    }

    static func cycled(for index: Int) -> KeywordStyle {
        let allStyles: [KeywordStyle] = [.outlined, .filled, .muted]
        return allStyles[index % allStyles.count]
    }
}
