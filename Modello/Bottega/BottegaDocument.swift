import Foundation

/// Role: one Codable snapshot. Works, pendant, marks, and catalog cache live here.
struct BottegaDocument: Sendable, Codable, Equatable {
    static let currentSchema = 1

    var schemaVersion: Int
    var works: [Work]
    var pendant: Pendant
    var twinMarks: [TwinMark]
    var breakMarks: [BreakMark]
    var catalogCache: [Work]
    var focusedObjectId: String?
    var onboardingComplete: Bool
    var nextSeq: Int
    var loadNotice: String?

    static let empty = BottegaDocument(
        schemaVersion: currentSchema,
        works: [],
        pendant: .idle,
        twinMarks: [],
        breakMarks: [],
        catalogCache: [],
        focusedObjectId: nil,
        onboardingComplete: false,
        nextSeq: 1,
        loadNotice: nil
    )

    var twinnedObjectIds: Set<String> {
        Set(twinMarks.map(\.studyObjectId))
    }

    var canMate: Bool {
        if case .installed(_, let trials) = pendant {
            return trials.contains { !$0.cooled }
        }
        return false
    }

    static func decode(from data: Data, decoder: JSONDecoder) throws -> BottegaDocument {
        let probe = try decoder.decode(SchemaProbe.self, from: data)
        switch probe.schemaVersion {
        case 1:
            var document = try decoder.decode(BottegaDocument.self, from: data)
            document.schemaVersion = 1
            return document
        default:
            throw BottegaStoreError.unsupportedSchema(probe.schemaVersion)
        }
    }
}

private struct SchemaProbe: Decodable {
    var schemaVersion: Int
}

enum BottegaStoreError: Error, Equatable, Sendable {
    case unsupportedSchema(Int)
    case corrupt
}
