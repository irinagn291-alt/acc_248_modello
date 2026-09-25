import Foundation

/// Role: storage seam. Views never touch UserDefaults or files.
actor BottegaVault {
    static let documentKey = "mdl.bottega.v1"
    static let backupKey = "mdl.bottega.v1.backup"
    static let demoKey = "mdl.demo.v1"

    private let defaults: UserDefaults
    private let directory: URL
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init(suiteName: String?, directory: URL) {
        if let suiteName, let suite = UserDefaults(suiteName: suiteName) {
            self.defaults = suite
        } else {
            self.defaults = .standard
        }
        self.directory = directory
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        self.encoder = encoder
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .useDefaultKeys
        self.decoder = decoder
    }

    func load() -> BottegaDocument {
        if let document = decode(defaults.data(forKey: Self.documentKey)) {
            return document
        }
        if let document = decode(defaults.data(forKey: Self.backupKey)) {
            var recovered = document
            recovered.loadNotice = "Restored the last good crate."
            return recovered
        }
        if let document = decodeFile(fileURL()) {
            return document
        }
        if let document = decodeFile(backupURL()) {
            var recovered = document
            recovered.loadNotice = "Restored the last good crate."
            return recovered
        }
        var empty = BottegaDocument.empty
        empty.loadNotice = "Started a fresh crate."
        return empty
    }

    func save(_ document: BottegaDocument) {
        var stored = document
        stored.loadNotice = nil
        guard let data = encode(stored) else { return }
        if let current = defaults.data(forKey: Self.documentKey) {
            defaults.set(current, forKey: Self.backupKey)
        }
        defaults.set(data, forKey: Self.documentKey)
        writeAtomically(data)
    }

    func reset() {
        defaults.removeObject(forKey: Self.documentKey)
        defaults.removeObject(forKey: Self.backupKey)
        removeIfPresent(fileURL())
        removeIfPresent(backupURL())
    }

    func hasDemoSeed() -> Bool {
        defaults.bool(forKey: Self.demoKey)
    }

    func markDemoSeeded() {
        defaults.set(true, forKey: Self.demoKey)
    }

    func clearDemoFlag() {
        defaults.removeObject(forKey: Self.demoKey)
    }

    private func encode(_ document: BottegaDocument) -> Data? {
        do {
            return try encoder.encode(document)
        } catch {
            return nil
        }
    }

    private func decode(_ data: Data?) -> BottegaDocument? {
        guard let data else { return nil }
        do {
            return try BottegaDocument.decode(from: data, decoder: decoder)
        } catch {
            return nil
        }
    }

    private func decodeFile(_ url: URL) -> BottegaDocument? {
        do {
            let data = try Data(contentsOf: url)
            return try BottegaDocument.decode(from: data, decoder: decoder)
        } catch {
            return nil
        }
    }

    private func writeAtomically(_ data: Data) {
        do {
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        } catch {
            return
        }
        let file = fileURL()
        let backup = backupURL()
        if FileManager.default.fileExists(atPath: file.path) {
            do {
                if FileManager.default.fileExists(atPath: backup.path) {
                    try FileManager.default.removeItem(at: backup)
                }
                try FileManager.default.copyItem(at: file, to: backup)
            } catch {
                // Keep going: the UserDefaults copy is already the durable backup.
            }
        }
        do {
            try data.write(to: file, options: .atomic)
        } catch {
            return
        }
    }

    private func removeIfPresent(_ url: URL) {
        guard FileManager.default.fileExists(atPath: url.path) else { return }
        do {
            try FileManager.default.removeItem(at: url)
        } catch {
            return
        }
    }

    private func fileURL() -> URL {
        directory.appendingPathComponent("bottega.json")
    }

    private func backupURL() -> URL {
        directory.appendingPathComponent("bottega.json.backup")
    }
}
