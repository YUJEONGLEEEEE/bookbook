import Foundation

// 디버그 빌드에서만 출력되는 로그 (릴리즈에선 no-op). 기존 print(...)를 일괄 대체.
func debugLog(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    #if DEBUG
    Swift.print(items.map { "\($0)" }.joined(separator: separator), terminator: terminator)
    #endif
}
