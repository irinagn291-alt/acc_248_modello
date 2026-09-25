import XCTest
@testable import Modello

final class PersistenceTests: XCTestCase {
    func test_roundTripWriteReload() async {
        let suite = "mdl.tests.\(UUID().uuidString)"
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent(suite, isDirectory: true)
        let vault = BottegaVault(suiteName: suite, directory: directory)
        let original = WorkFixtures.installed()
        await vault.save(original)
        let reloaded = await vault.load()
        XCTAssertEqual(reloaded.works.count, original.works.count)
        XCTAssertEqual(reloaded.pendant, original.pendant)
        XCTAssertEqual(reloaded.schemaVersion, 1)
        XCTAssertTrue(reloaded.onboardingComplete)
    }

    func test_corruptFileFallsBackThenEmpty() async {
        let suite = "mdl.tests.\(UUID().uuidString)"
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent(suite, isDirectory: true)
        let vault = BottegaVault(suiteName: suite, directory: directory)
        await vault.save(WorkFixtures.installed())
        if let defaults = UserDefaults(suiteName: suite) {
            defaults.set(Data("not-json".utf8), forKey: BottegaVault.documentKey)
            defaults.removeObject(forKey: BottegaVault.backupKey)
        }
        let file = directory.appendingPathComponent("bottega.json")
        do {
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            try Data("broken".utf8).write(to: file, options: .atomic)
            try Data("broken".utf8).write(
                to: directory.appendingPathComponent("bottega.json.backup"),
                options: .atomic
            )
        } catch {
            return XCTFail("could not write corrupt files")
        }
        let loaded = await vault.load()
        XCTAssertEqual(loaded.works, [])
        XCTAssertEqual(loaded.pendant, .idle)
        XCTAssertEqual(loaded.loadNotice, "Started a fresh crate.")
    }

    func test_resetAllDataClearsVault() async {
        let suite = "mdl.tests.\(UUID().uuidString)"
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent(suite, isDirectory: true)
        let vault = BottegaVault(suiteName: suite, directory: directory)
        await vault.save(WorkFixtures.installed())
        let studio = await MainActor.run {
            BottegaStudio(vault: vault, document: WorkFixtures.installed())
        }
        await studio.resetAllData()
        let snapshot = await studio.document
        XCTAssertEqual(snapshot, BottegaDocument.empty)
        let loaded = await vault.load()
        XCTAssertTrue(loaded.works.isEmpty)
    }

    func test_dayEdgeIsYYYYMMDD() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .gmt
        var parts = DateComponents()
        parts.year = 2026
        parts.month = 9
        parts.day = 21
        parts.hour = 18
        guard let date = calendar.date(from: parts) else {
            return XCTFail("date")
        }
        XCTAssertEqual(DayEdge.key(on: date, calendar: calendar), 20260921)
        XCTAssertNotEqual(DayEdge.label(dayKey: 20260921, calendar: calendar), "unknown")
    }
}
