import Foundation

enum SecretObfuscator {
    private static let cipher: [UInt8] = [0x5B, 0x2C, 0xE7, 0x91, 0x3A, 0x6D, 0xC4, 0x18]

    static func decode(_ bytes: [UInt8]) -> String {
        let decoded = bytes.enumerated().map { $0.element ^ cipher[$0.offset % cipher.count] }
        return String(decoding: decoded, as: UTF8.self)
    }

    static func encodeLiteral(_ text: String) -> String {
        let bytes = Array(text.utf8).enumerated().map { $0.element ^ cipher[$0.offset % cipher.count] }
        return "[" + bytes.map { "0x" + String(format: "%02X", $0) }.joined(separator: ", ") + "]"
    }
}
