import Foundation

/// Role: a reviewable miss. Written when the tapped Trial is another maker.
struct BreakMark: Identifiable, Hashable, Sendable, Codable, Equatable {
    var id: String
    var studyObjectId: String
    var trialObjectId: String
    var dayKey: Int
    var seq: Int
}
