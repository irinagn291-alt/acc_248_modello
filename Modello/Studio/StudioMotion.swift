import SwiftUI

/// Role: snap motion. Reduce Motion keeps fade only.
enum StudioMotion {
    static let duration: Double = 0.16
    static let pressScale: CGFloat = 0.97
    static let sheetScale: CGFloat = 0.96

    static func ease(_ reduceMotion: Bool) -> Animation {
        .easeOut(duration: duration)
    }
}

/// Role: sheets fade, and scale from sheetScale unless Reduce Motion.
struct StudioSheetGate<Content: View>: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var risen = false
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .scaleEffect(risen || reduceMotion ? 1 : StudioMotion.sheetScale)
            .opacity(risen ? 1 : 0)
            .onAppear {
                withAnimation(StudioMotion.ease(reduceMotion)) {
                    risen = true
                }
            }
    }
}
