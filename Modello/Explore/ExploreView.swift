import SwiftUI

/// Role: first-class Explore sheet. Search stores a Work free.
struct ExploreView: View {
    @ObservedObject var studio: BottegaStudio
    var onClose: () -> Void

    @StateObject private var desk = ExploreDesk()
    @FocusState private var fieldFocused: Bool

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: StudioSpace.sm) {
                TextField("Search a maker or title", text: $desk.query)
                    .font(StudioType.body)
                    .foregroundStyle(StudioInk.ink)
                    .padding(StudioSpace.sm)
                    .background(StudioInk.surface)
                    .clipShape(RoundedRectangle(cornerRadius: StudioRadius.chip, style: .continuous))
                    .focused($fieldFocused)
                    .submitLabel(.search)
                    .onChange(of: desk.query) { _, next in
                        desk.schedule(query: next, cached: studio.document.catalogCache) { works in
                            studio.rememberCatalog(works)
                        }
                    }
                content
            }
            .padding(.horizontal, StudioSpace.md)
            .padding(.top, StudioSpace.sm)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(StudioInk.background.ignoresSafeArea())
            .scrollDismissesKeyboard(.immediately)
            .navigationTitle("Explore")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .frame(width: 44, height: 44)
                    }
                    .buttonStyle(StudioChipStyle())
                    .accessibilityLabel("Close Explore")
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") { fieldFocused = false }
                }
            }
        }
        .presentationBackground(StudioInk.background)
    }

    @ViewBuilder
    private var content: some View {
        switch desk.phase {
        case .empty:
            emptyPlate
        case .vacant:
            vacantPlate
        case .loading:
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .tint(StudioInk.accent)
        case .filled(let works):
            ScrollView {
                LazyVStack(spacing: StudioSpace.sm) {
                    ForEach(works) { work in
                        Button {
                            studio.store(work)
                            fieldFocused = false
                        } label: {
                            workRow(work)
                        }
                        .buttonStyle(StudioChipStyle())
                    }
                }
                .padding(.bottom, StudioSpace.lg)
            }
            .scrollDismissesKeyboard(.interactively)
        case .failed(let message):
            errorPlate(message)
        }
    }

    private var emptyPlate: some View {
        VStack(alignment: .leading, spacing: StudioSpace.sm) {
            Image("mdl_EmptyList")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .accessibilityHidden(true)
            Text("Search the crate")
                .font(StudioType.title)
                .foregroundStyle(StudioInk.ink)
            Text("Type a maker. The Frick shelf answers when the line is quiet.")
                .font(StudioType.body)
                .foregroundStyle(StudioInk.muted)
            Button("Browse Bellini") {
                desk.query = "Bellini"
                desk.schedule(query: "Bellini", cached: studio.document.catalogCache) { works in
                    studio.rememberCatalog(works)
                }
            }
            .buttonStyle(StudioPillStyle())
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var vacantPlate: some View {
        VStack(alignment: .leading, spacing: StudioSpace.sm) {
            Image("mdl_EmptyList")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .accessibilityHidden(true)
            Text("No painting for that word")
                .font(StudioType.title)
                .foregroundStyle(StudioInk.ink)
            Text("Try a maker from the shelf, such as Bellini.")
                .font(StudioType.body)
                .foregroundStyle(StudioInk.muted)
            Button("Browse Bellini") {
                desk.query = "Bellini"
                desk.schedule(query: "Bellini", cached: studio.document.catalogCache) { works in
                    studio.rememberCatalog(works)
                }
            }
            .buttonStyle(StudioPillStyle())
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func errorPlate(_ message: String) -> some View {
        VStack(alignment: .leading, spacing: StudioSpace.sm) {
            Text("Search did not finish")
                .font(StudioType.title)
                .foregroundStyle(StudioInk.ink)
            Text(message)
                .font(StudioType.body)
                .foregroundStyle(StudioInk.muted)
            Button("Try again") {
                desk.retry(cached: studio.document.catalogCache) { works in
                    studio.rememberCatalog(works)
                }
            }
            .buttonStyle(StudioPillStyle())
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        .padding(.bottom, StudioSpace.md)
    }

    private func workRow(_ work: Work) -> some View {
        HStack(spacing: StudioSpace.sm) {
            WorkPlate(work: work, fallback: "mdl_CardBackdrop", corner: StudioRadius.chip)
                .frame(width: 72, height: 72)
            VStack(alignment: .leading, spacing: 0) {
                Text(work.title)
                    .font(StudioType.title)
                    .foregroundStyle(StudioInk.ink)
                    .lineLimit(2)
                Text(work.maker)
                    .font(StudioType.callout)
                    .foregroundStyle(StudioInk.muted)
                    .lineLimit(1)
            }
            Spacer(minLength: 0)
            Text(studio.document.works.contains(where: { $0.id == work.id }) ? "Saved" : "Save")
                .font(StudioType.caption)
                .foregroundStyle(studio.document.focusedObjectId == work.id ? StudioInk.accent : StudioInk.ink)
        }
        .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
    }
}

/// Role: owns Explore search state. A new query cancels the last task.
@MainActor
final class ExploreDesk: ObservableObject {
    enum Phase: Equatable {
        case empty
        case vacant
        case loading
        case filled([Work])
        case failed(String)
    }

    @Published var query: String = ""
    @Published var phase: Phase = .empty

    private let client = CrateClient()
    private var work: Task<Void, Never>?

    func schedule(query: String, cached: [Work], remember: @escaping ([Work]) -> Void) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        work?.cancel()
        if trimmed.isEmpty {
            phase = .empty
            return
        }
        work = Task {
            let spinner = Task {
                try? await Task.sleep(nanoseconds: 150_000_000)
                if !Task.isCancelled {
                    phase = .loading
                }
            }
            defer { spinner.cancel() }
            do {
                try await Task.sleep(nanoseconds: 300_000_000)
                if Task.isCancelled { return }
                let found = try await client.search(query: trimmed)
                let rows = found.isEmpty
                    ? CrateClient.localHits(query: trimmed, cached: cached, shelf: FrickShelf.works)
                    : found
                if Task.isCancelled { return }
                if rows.isEmpty {
                    phase = .vacant
                } else {
                    phase = .filled(rows)
                    remember(rows)
                }
            } catch CrateError.cancelled {
                return
            } catch is CancellationError {
                return
            } catch {
                if Task.isCancelled { return }
                let rows = CrateClient.localHits(query: trimmed, cached: cached, shelf: FrickShelf.works)
                if rows.isEmpty {
                    phase = .failed("Search could not reach the crate. Try again, or use a shelf name.")
                } else {
                    phase = .filled(rows)
                    remember(rows)
                }
            }
        }
    }

    func retry(cached: [Work], remember: @escaping ([Work]) -> Void) {
        schedule(query: query, cached: cached, remember: remember)
    }
}

/// Role: 3.6 Explore destination for the live driver. Same sheet as ExploreView.
struct ExploreHub: View {
    @ObservedObject var studio: BottegaStudio
    var onClose: () -> Void

    var body: some View {
        ExploreView(studio: studio, onClose: onClose)
    }
}
