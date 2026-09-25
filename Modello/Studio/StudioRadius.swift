import SwiftUI

/// Role: the only radius and elevation accessor.
enum StudioRadius {
    static let card: CGFloat = 20
    static let chip: CGFloat = 12

    static let lift = ShadowStyle()

    struct ShadowStyle {
        let color = Color.black.opacity(0.10)
        let radius: CGFloat = 16
        let y: CGFloat = 8
    }
}
