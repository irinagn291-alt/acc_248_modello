import Combine
import Foundation

/// Role: in-memory source of truth. The vault is a projection of this document.
@MainActor
final class BottegaStudio: ObservableObject {
    @Published private(set) var document: BottegaDocument
    @Published private(set) var dayKey: Int

    private let vault: BottegaVault
    private var persistTask: Task<Void, Never>?

    init(vault: BottegaVault, document: BottegaDocument) {
        self.vault = vault
        self.document = document
        self.dayKey = DayEdge.key()
    }

    static func open(suiteName: String?, directory: URL) async -> BottegaStudio {
        let vault = BottegaVault(suiteName: suiteName, directory: directory)
        let loaded = await vault.load()
        let studio = BottegaStudio(vault: vault, document: loaded)
        await studio.seedIfNeeded()
        return studio
    }

    func install(seed: UInt64 = 1) {
        var generator = CrateEntropy(seed: seed)
        let (next, _) = Bottega.install(document, generator: &generator)
        replace(next)
    }

    func mate(trialId: String) {
        let (next, _) = Bottega.mate(trialId: trialId, in: document)
        replace(next)
    }

    func retract() {
        let (next, _) = Bottega.retract(document)
        replace(next)
    }

    func store(_ work: Work) {
        replace(Bottega.store(work, in: document))
    }

    func rememberCatalog(_ works: [Work]) {
        replace(Bottega.rememberCatalog(works, in: document))
    }

    func finishOnboarding() {
        var next = document
        next.onboardingComplete = true
        replace(next)
    }

    func resetAllData() async {
        persistTask?.cancel()
        persistTask = nil
        document = BottegaDocument.empty
        await vault.reset()
        await vault.save(document)
    }

    func flush() async {
        persistTask?.cancel()
        persistTask = nil
        let snapshot = document
        await vault.save(snapshot)
    }

    func applyScenePhaseInactive() async {
        await flush()
        noteCalendarDay()
    }

    func noteCalendarDay() {
        dayKey = DayEdge.key()
    }

    func dismissNotice() {
        var next = document
        next.loadNotice = nil
        document = next
    }

    private func replace(_ next: BottegaDocument) {
        document = next
        schedulePersist()
    }

    private func schedulePersist() {
        persistTask?.cancel()
        let snapshot = document
        persistTask = Task { [vault] in
            do {
                try await Task.sleep(nanoseconds: 350_000_000)
            } catch {
                return
            }
            if Task.isCancelled { return }
            await vault.save(snapshot)
        }
    }

    private func seedIfNeeded() async {
#if targetEnvironment(simulator)
        let already = await vault.hasDemoSeed()
        if already { return }
        if document.works.isEmpty {
            document = FrickShelf.seededDocument()
        }
        await vault.save(document)
        await vault.markDemoSeeded()
#endif
    }
}
