import SwiftUI

/// Role: reset, contact, Frick credit, and a door back into onboarding.
struct SettingsView: View {
    @ObservedObject var studio: BottegaStudio
    var onClose: () -> Void
    var onReplayOnboarding: () -> Void

    @State private var confirmReset = false
    @State private var creditOpen = false

    private let contact = URL(string: "https://modello-studio.pro/contact-us")
    private let frick = FrickShelf.creditURL

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: StudioSpace.md) {
                    if studio.document.works.isEmpty, let notice = studio.document.loadNotice {
                        errorPlate(notice)
                    } else {
                        housePlate
                    }
                    Button("Walk onboarding again", action: onReplayOnboarding)
                        .buttonStyle(StudioChipStyle())
                    if let contact {
                        Link(destination: contact) {
                            Text("Contact us")
                                .font(StudioType.title)
                                .foregroundStyle(StudioInk.ink)
                                .frame(maxWidth: .infinity, minHeight: 52)
                                .background(StudioInk.surface)
                                .clipShape(RoundedRectangle(cornerRadius: StudioRadius.card, style: .continuous))
                        }
                        .contentShape(Rectangle())
                    }
                    if let frick {
                        Button {
                            creditOpen = true
                        } label: {
                            VStack(alignment: .leading, spacing: StudioSpace.xs) {
                                Text("Catalog credit")
                                    .font(StudioType.caption)
                                    .foregroundStyle(StudioInk.muted)
                                Text(FrickShelf.creditName)
                                    .font(StudioType.title)
                                    .foregroundStyle(StudioInk.ink)
                                Text("Tap to read the collection source.")
                                    .font(StudioType.callout)
                                    .foregroundStyle(StudioInk.muted)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(StudioSpace.sm)
                            .background(StudioInk.surface)
                            .clipShape(RoundedRectangle(cornerRadius: StudioRadius.card, style: .continuous))
                        }
                        .buttonStyle(StudioChipStyle())
                        .sheet(isPresented: $creditOpen) {
                            creditSheet(frick)
                        }
                    }
                    Button("Reset all data") { confirmReset = true }
                        .buttonStyle(StudioResetStyle())
                }
                .padding(StudioSpace.md)
                .padding(.bottom, StudioSpace.lg)
            }
            .background(StudioInk.background.ignoresSafeArea())
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .frame(width: 44, height: 44)
                    }
                    .buttonStyle(StudioChipStyle())
                    .accessibilityLabel("Close Settings")
                }
            }
            .confirmationDialog(
                "Reset the crate? Works, TwinMarks, and BreakMarks leave this device.",
                isPresented: $confirmReset,
                titleVisibility: .visible
            ) {
                Button("Reset the crate", role: .destructive) {
                    Task { await studio.resetAllData() }
                }
                Button("Keep the crate", role: .cancel) {}
            }
        }
        .presentationBackground(StudioInk.background)
    }

    private var savedCountLine: String {
        StudioFigures.count(studio.document.works.count) + " saved paintings"
    }

    private var housePlate: some View {
        VStack(alignment: .leading, spacing: StudioSpace.xs) {
            Text("This device")
                .font(StudioType.caption)
                .foregroundStyle(StudioInk.muted)
            Text("Works stay on this phone. One collection voice.")
                .font(StudioType.body)
                .foregroundStyle(StudioInk.ink)
            Text(savedCountLine)
                .font(StudioType.figure)
                .foregroundStyle(StudioInk.ink)
        }
        .padding(StudioSpace.sm)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(StudioInk.surface)
        .clipShape(RoundedRectangle(cornerRadius: StudioRadius.card, style: .continuous))
    }

    private func errorPlate(_ notice: String) -> some View {
        VStack(alignment: .leading, spacing: StudioSpace.xs) {
            Text("Settings opened on a fresh crate")
                .font(StudioType.title)
                .foregroundStyle(StudioInk.ink)
            Text(notice)
                .font(StudioType.body)
                .foregroundStyle(StudioInk.muted)
        }
        .padding(StudioSpace.sm)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(StudioInk.surface)
        .clipShape(RoundedRectangle(cornerRadius: StudioRadius.card, style: .continuous))
    }

    private func creditSheet(_ url: URL) -> some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: StudioSpace.sm) {
                Text(FrickShelf.creditName)
                    .font(StudioType.display)
                    .foregroundStyle(StudioInk.ink)
                Text("Search and the local shelf draw from this collection.")
                    .font(StudioType.body)
                    .foregroundStyle(StudioInk.muted)
                Link("Open The Frick Collection", destination: url)
                    .font(StudioType.title)
                    .foregroundStyle(StudioInk.accent)
                    .frame(maxWidth: .infinity, minHeight: 52, alignment: .leading)
                Spacer()
            }
            .padding(StudioSpace.md)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(StudioInk.background.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") { creditOpen = false }
                        .buttonStyle(StudioChipStyle())
                }
            }
        }
    }
}
