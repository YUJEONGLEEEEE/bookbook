
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

    // 작가 표시용: HTML 제거 + "(지은이)" 제거 + 공백/쉼표 정리
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
            formatter.dateFormat = "yyyy-MM-dd"
            formatter.locale = Locale(identifier: "ko_KR")
            return formatter.date(from: self) ?? Date()
        }
}
