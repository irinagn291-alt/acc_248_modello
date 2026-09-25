import Foundation

/// Role: a saved painting in the crate. Identity is the collection object id.
struct Work: Identifiable, Hashable, Sendable, Codable, Equatable {
    var id: String
    var title: String
    var maker: String
    var imageURL: String
}
