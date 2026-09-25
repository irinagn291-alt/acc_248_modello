import Foundation

/// Role: a filed mate. Written only when the tapped Trial shares the Study maker.
struct TwinMark: Identifiable, Hashable, Sendable, Codable, Equatable {
    var id: String
    var studyObjectId: String
    var trialObjectId: String
    var dayKey: Int
    var seq: Int
}
