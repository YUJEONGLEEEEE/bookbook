
import Foundation

extension String {
    func cleanHTML() -> String {
        self
            .replacingOccurrences(of: "<b>", with: "")
            .replacingOccurrences(of: "</b>", with: "")
            .replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
            .replacingOccurrences(of: "&lt;", with: "<")
            .replacingOccurrences(of: "&gt;", with: ">")
            .replacingOccurrences(of: "&amp;", with: "&")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func cleanAuthor() -> String {
        var result = cleanHTML().replacingOccurrences(of: "(지은이)", with: "")
        result = result.replacingOccurrences(of: " ,", with: ",")
        while result.contains("  ") {
            result = result.replacingOccurrences(of: "  ", with: " ")
        }
        return result.trimmingCharacters(in: CharacterSet(charactersIn: " ,"))
    }

    func toDate() -> Date {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        for format in ["yyyyMMdd", "yyyy-MM-dd", "yyyy.MM.dd"] {
            formatter.dateFormat = format
            if let date = formatter.date(from: self) { return date }
        }
        return Date()
    }
}
