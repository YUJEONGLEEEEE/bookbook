
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
        formatter.locale = Locale(identifier: "en_US_POSIX")   // 고정 포맷 파싱엔 POSIX 권장
        // 네이버 pubdate는 "yyyyMMdd", 다른 소스는 하이픈/점 포맷일 수 있어 순서대로 시도
        for format in ["yyyyMMdd", "yyyy-MM-dd", "yyyy.MM.dd"] {
            formatter.dateFormat = format
            if let date = formatter.date(from: self) { return date }
        }
        return Date()
    }
}
