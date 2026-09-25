import Foundation

/// Role: the pinned painting on Quiz. Install writes one Study from a free Work.
struct Study: Hashable, Sendable, Codable, Equatable {
    var work: Work

    var objectId: String { work.id }
    var maker: String { work.maker }
}
