import Foundation

enum AppLog {
    /// The one switch. Set to false to silence every print in the app.
    // static let isEnabled = false
    static let isEnabled: Bool = {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }()
}

/// Shadows Swift.print for the whole NextPro module.
func print(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    guard AppLog.isEnabled else { return }
    let output = items.map { "\($0)" }.joined(separator: separator)
    Swift.print(output, terminator: terminator)
}
