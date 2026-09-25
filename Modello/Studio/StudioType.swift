import SwiftUI

/// Role: the only type accessor. Six steps, Semibold and Regular, SF Pro.
enum StudioType {
    static let display = Font.system(.title, design: .default).weight(.semibold)
    static let title = Font.system(.title3, design: .default).weight(.semibold)
    static let body = Font.system(.body, design: .default).weight(.regular)
    static let callout = Font.system(.callout, design: .default).weight(.regular)
    static let caption = Font.system(.caption, design: .default).weight(.regular)
    static let figure = Font.system(.body, design: .default).weight(.semibold).monospacedDigit()
}
