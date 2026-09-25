import Foundation

enum CrateError: Error, Equatable, Sendable {
    case cancelled
    case notFound
    case decoding
    case transport
    case http(Int)
}
