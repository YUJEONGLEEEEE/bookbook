import Foundation

extension String {
    var objectParticle: String {
        guard let last = unicodeScalars.last else { return "을" }
        let code = last.value
        guard code >= 0xAC00, code <= 0xD7A3 else { return "을" }
        return (code - 0xAC00) % 28 == 0 ? "를" : "을"
    }
}
