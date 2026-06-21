import Foundation

// API 시크릿 키를 바이너리에서 '평문'으로 추출되지 않도록 하는 경량 난독화(XOR).
// 주의: 완전한 보안이 아니라 `strings` 등 단순 추출을 막기 위한 클라이언트 측 완화책이다.
// 실서비스 수준 보호가 필요하면 키를 서버에 두고 백엔드 프록시를 통해 호출해야 한다.
enum SecretObfuscator {
    // 난독화에 사용하는 XOR 키(임의값). 길이 무관하게 순환 적용된다.
    private static let cipher: [UInt8] = [0x5B, 0x2C, 0xE7, 0x91, 0x3A, 0x6D, 0xC4, 0x18]

    /// 난독 바이트 배열 → 원본 문자열
    static func decode(_ bytes: [UInt8]) -> String {
        let decoded = bytes.enumerated().map { $0.element ^ cipher[$0.offset % cipher.count] }
        return String(decoding: decoded, as: UTF8.self)
    }

    /// 원본 문자열 → 난독 바이트 배열 리터럴 (새 키 등록 시 디버그에서만 사용)
    static func encodeLiteral(_ text: String) -> String {
        let bytes = Array(text.utf8).enumerated().map { $0.element ^ cipher[$0.offset % cipher.count] }
        return "[" + bytes.map { "0x" + String(format: "%02X", $0) }.joined(separator: ", ") + "]"
    }
}
