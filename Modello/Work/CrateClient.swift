import Foundation

/// Role: one client for both cgi/search.pl list and object resolve.
struct CrateClient: Sendable {
    static let userAgent = "Modello/1.0 (iOS; +https://modello-studio.pro)"
    static let host = "https://collections.frick.org"

    private let transport: any CrateTransport
    private let decoder: JSONDecoder

    init(transport: any CrateTransport) {
        self.transport = transport
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .useDefaultKeys
        self.decoder = decoder
    }

    init(session: URLSession? = nil) {
        let resolved: URLSession
        if let session {
            resolved = session
        } else {
            let configuration = URLSessionConfiguration.ephemeral
            configuration.timeoutIntervalForRequest = 15
            configuration.timeoutIntervalForResource = 15
            configuration.httpAdditionalHeaders = ["User-Agent": Self.userAgent]
            resolved = URLSession(configuration: configuration)
        }
        self.init(transport: SessionCrateTransport(session: resolved))
    }

    func search(query: String, page: Int = 1, pageSize: Int = 12) async throws -> [Work] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return [] }
        let url = searchURL(terms: trimmed, page: page, pageSize: pageSize)
        let data = try await fetch(url, retryOnTransport: true)
        let dto: CrateSearchDTO
        do {
            dto = try decoder.decode(CrateSearchDTO.self, from: data)
        } catch {
            throw CrateError.decoding
        }
        if dto.status == 0 {
            throw CrateError.notFound
        }
        return dto.rows.compactMap { $0.asWork() }
    }

    func resolve(objectId: String) async throws -> Work {
        let trimmed = objectId.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { throw CrateError.notFound }
        let url = resolveURL(objectId: trimmed)
        let data = try await fetch(url, retryOnTransport: true)
        if let search = try? decoder.decode(CrateSearchDTO.self, from: data) {
            if search.status == 0 { throw CrateError.notFound }
            if let work = search.rows.compactMap({ $0.asWork() }).first {
                return work
            }
        }
        do {
            let dto = try decoder.decode(CrateResolveDTO.self, from: data)
            if dto.status == 0 { throw CrateError.notFound }
            if let work = dto.hit?.asWork() ?? dto.product?.asWork() {
                return work
            }
            throw CrateError.notFound
        } catch let error as CrateError {
            throw error
        } catch {
            throw CrateError.decoding
        }
    }

    func browse(
        query: String,
        page: Int = 1,
        cached: [Work],
        shelf: [Work] = FrickShelf.works
    ) async -> [Work] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return [] }
        do {
            let found = try await search(query: trimmed, page: page)
            if found.isEmpty {
                return Self.localHits(query: trimmed, cached: cached, shelf: shelf)
            }
            return found
        } catch CrateError.cancelled {
            return []
        } catch {
            return Self.localHits(query: trimmed, cached: cached, shelf: shelf)
        }
    }

    func makeSearchRequest(terms: String, page: Int, pageSize: Int) -> URLRequest {
        var request = URLRequest(url: searchURL(terms: terms, page: page, pageSize: pageSize))
        request.setValue(Self.userAgent, forHTTPHeaderField: "User-Agent")
        request.timeoutInterval = 15
        return request
    }

    static func localHits(query: String, cached: [Work], shelf: [Work]) -> [Work] {
        let needle = query.lowercased()
        let pool = cached + shelf
        var seen: Set<String> = []
        var hits: [Work] = []
        for work in pool {
            if seen.contains(work.id) { continue }
            let hay = "\(work.title) \(work.maker)".lowercased()
            if hay.contains(needle) {
                seen.insert(work.id)
                hits.append(work)
            }
        }
        return hits
    }

    private func searchURL(terms: String, page: Int, pageSize: Int) -> URL {
        var components = URLComponents(string: "\(Self.host)/cgi/search.pl")
        components?.queryItems = [
            URLQueryItem(name: "search_terms", value: terms),
            URLQueryItem(name: "json", value: "1"),
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "page_size", value: String(pageSize)),
        ]
        return components?.url ?? URL(fileURLWithPath: "/cgi/search.pl")
    }

    private func resolveURL(objectId: String) -> URL {
        var components = URLComponents(string: "\(Self.host)/cgi/search.pl")
        components?.queryItems = [
            URLQueryItem(name: "objectid", value: objectId),
            URLQueryItem(name: "json", value: "1"),
        ]
        return components?.url ?? URL(fileURLWithPath: "/cgi/search.pl")
    }

    private func fetch(_ url: URL, retryOnTransport: Bool) async throws -> Data {
        try Task.checkCancellation()
        var request = URLRequest(url: url)
        request.setValue(Self.userAgent, forHTTPHeaderField: "User-Agent")
        request.timeoutInterval = 15
        do {
            let (data, response) = try await transport.data(for: request)
            try Task.checkCancellation()
            if let http = response as? HTTPURLResponse {
                if http.statusCode == 404 {
                    throw CrateError.notFound
                }
                if !(200...299).contains(http.statusCode) {
                    throw CrateError.http(http.statusCode)
                }
            }
            return data
        } catch is CancellationError {
            throw CrateError.cancelled
        } catch let error as CrateError {
            throw error
        } catch {
            if retryOnTransport {
                return try await fetch(url, retryOnTransport: false)
            }
            throw CrateError.transport
        }
    }
}
