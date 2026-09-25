import Foundation

protocol CrateTransport: Sendable {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

struct SessionCrateTransport: CrateTransport {
    let session: URLSession

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        try await session.data(for: request)
    }
}
