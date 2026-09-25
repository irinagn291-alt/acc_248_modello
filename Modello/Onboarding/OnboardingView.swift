import SwiftUI

/// Role: first walk through the pendant. Skip still writes defaults.
struct OnboardingView: View {
    @ObservedObject var studio: BottegaStudio
    var onFinished: () -> Void

    @State private var page = 0

    private let pages: [(image: String, title: String, body: String)] = [
        ("mdl_Onboarding1", "Hang a study", "Save museum paintings, then pin one as the hanging study."),
        ("mdl_Onboarding2", "Mate same hand", "Tap the painting by the same maker. A miss cools that tile."),
        ("mdl_Onboarding3", "File the twin", "A mate writes a twin. Misses stay reviewable on Saved."),
        ("mdl_HeaderDecor", "Stay on device", "The Frick Collection shelf fills the crate when search is quiet."),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: StudioSpace.md) {
            HStack {
                Spacer()
                Button("Skip") { finish() }
                    .buttonStyle(StudioChipStyle())
                    .accessibilityLabel("Skip onboarding")
            }
            .padding(.horizontal, StudioSpace.md)
            pagePlate
            Button(page == pages.count - 1 ? "Start" : "Next") {
                if page == pages.count - 1 {
                    finish()
                } else {
                    page += 1
                }
            }
            .buttonStyle(StudioPillStyle())
            .padding(.horizontal, StudioSpace.md)
            .padding(.bottom, StudioSpace.md)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(StudioInk.background.ignoresSafeArea())
    }

    private var pagePlate: some View {
        let pageItem = pages[page]
        return VStack(alignment: .leading, spacing: StudioSpace.sm) {
            Image(pageItem.image)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .accessibilityHidden(true)
            Text(pageItem.title)
                .font(StudioType.display)
                .foregroundStyle(StudioInk.ink)
                .lineLimit(2)
            Text(pageItem.body)
                .font(StudioType.body)
                .foregroundStyle(StudioInk.muted)
        }
        .padding(.horizontal, StudioSpace.md)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
    }

    private func finish() {
        studio.finishOnboarding()
        onFinished()
    }
}
