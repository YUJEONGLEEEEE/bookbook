import Foundation

extension String {
    // 한글 목적격 조사(을/를): 마지막 글자에 받침이 있으면 '을', 없으면 '를'
    var objectParticle: String {
        guard let last = unicodeScalars.last else { return "을" }
        let code = last.value
        guard code >= 0xAC00, code <= 0xD7A3 else { return "을" }
        return (code - 0xAC00) % 28 == 0 ? "를" : "을"
    }
}
