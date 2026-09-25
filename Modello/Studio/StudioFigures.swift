import Foundation

/// Role: locale figures for TwinMark and BreakMark counts.
enum StudioFigures {
    private static let integer: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter
    }()

    static func count(_ value: Int) -> String {
        integer.string(from: NSNumber(value: value)) ?? "0"
    }
}
