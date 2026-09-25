import SwiftUI

/// Role: the twist screen. Install-then-mate has its own surface plus Quiz.
struct InstallMateView: View {
    var onClose: () -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: StudioSpace.md) {
                    Image("mdl_TwistHero")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .accessibilityHidden(true)
                    Text("Install then mate")
                        .font(StudioType.display)
                        .foregroundStyle(StudioInk.ink)
                    Text("Install pins a saved painting that still has a same-hand sibling. Four tiles hang: one sibling, three other makers.")
                        .font(StudioType.body)
                        .foregroundStyle(StudioInk.muted)
                    Text("Tap the sibling to file a twin. A miss files a break and keeps the hanging painting.")
                        .font(StudioType.body)
                        .foregroundStyle(StudioInk.muted)
                    Text("Mate while idle is refused. A second install while a painting hangs is refused.")
                        .font(StudioType.body)
                        .foregroundStyle(StudioInk.muted)
                }
                .padding(StudioSpace.md)
            }
            .background(StudioInk.background.ignoresSafeArea())
            .navigationTitle("Install then mate")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .frame(width: 44, height: 44)
                    }
                    .buttonStyle(StudioChipStyle())
                    .accessibilityLabel("Close install then mate")
                }
            }
        }
        .presentationBackground(StudioInk.background)
    }
}
