import XCTest
@testable import Modello

final class CrateClientTests: XCTestCase {
    func test_searchRequestUsesCgiSearchAndUserAgent() {
        let client = CrateClient(transport: StubCrateTransport(events: []))
        let request = client.makeSearchRequest(terms: "bellini", page: 1, pageSize: 12)
        XCTAssertEqual(request.url?.path, "/cgi/search.pl")
        XCTAssertEqual(request.value(forHTTPHeaderField: "User-Agent"), CrateClient.userAgent)
        XCTAssertTrue(request.url?.query?.contains("search_terms=bellini") == true)
        XCTAssertTrue(request.url?.query?.contains("json=1") == true)
        XCTAssertEqual(request.timeoutInterval, 15)
        XCTAssertFalse(CrateClient.userAgent.contains("Horsserie"))
    }

    func test_searchMapsDTOToWork() async throws {
        let body = """
        {"status":1,"hits":[{"objectid":"1915.1.03","title":"Saint Francis in the Desert","maker":"Giovanni Bellini","image_url":"https://collections.frick.org/media/a.jpg"}]}
        """
        let transport = StubCrateTransport(events: [
            .success(http(200, body: Data(body.utf8))),
        ])
        let client = CrateClient(transport: transport)
        let works = try await client.search(query: "francis")
        XCTAssertEqual(works.count, 1)
        XCTAssertEqual(works.first?.id, "1915.1.03")
        XCTAssertEqual(works.first?.maker, "Giovanni Bellini")
    }

    func test_statusZeroIsNotFound() async {
        let body = #"{"status":0,"hits":[]}"#
        let transport = StubCrateTransport(events: [
            .success(http(200, body: Data(body.utf8))),
        ])
        let client = CrateClient(transport: transport)
        do {
            _ = try await client.search(query: "missing")
            XCTFail("expected not found")
        } catch CrateError.notFound {
            XCTAssertTrue(true)
        } catch {
            XCTFail("wrong error")
        }
    }

    func test_malformedJSONIsDecodingError() async {
        let transport = StubCrateTransport(events: [
            .success(http(200, body: Data("not-json".utf8))),
        ])
        let client = CrateClient(transport: transport)
        do {
            _ = try await client.search(query: "x")
            XCTFail("expected decoding")
        } catch CrateError.decoding {
            XCTAssertTrue(true)
        } catch {
            XCTFail("wrong error")
        }
    }

    func test_doesNotRetry404() async {
        let transport = StubCrateTransport(events: [
            .success(http(404, body: Data())),
            .success(http(200, body: Data(#"{"status":1,"hits":[]}"#.utf8))),
        ])
        let client = CrateClient(transport: transport)
        do {
            _ = try await client.search(query: "gone")
            XCTFail("expected 404")
        } catch CrateError.notFound {
            XCTAssertEqual(transport.calls, 1)
        } catch {
            XCTFail("wrong error")
        }
    }

    func test_retriesTransientTransportOnce() async throws {
        let body = #"{"status":1,"hits":[]}"#
        let transport = StubCrateTransport(events: [
            .failure(URLError(.timedOut)),
            .success(http(200, body: Data(body.utf8))),
        ])
        let client = CrateClient(transport: transport)
        let works = try await client.search(query: "goya")
        XCTAssertEqual(works, [])
        XCTAssertEqual(transport.calls, 2)
    }

    func test_browseFallsBackToShelf() async {
        let transport = StubCrateTransport(events: [
            .failure(URLError(.notConnectedToInternet)),
            .failure(URLError(.notConnectedToInternet)),
        ])
        let client = CrateClient(transport: transport)
        let hits = await client.browse(query: "Bellini", cached: [])
        XCTAssertTrue(hits.contains { $0.maker == "Giovanni Bellini" })
    }

    func test_emptyQueryDoesNotHitNetwork() async throws {
        let transport = StubCrateTransport(events: [])
        let client = CrateClient(transport: transport)
        let works = try await client.search(query: "   ")
        XCTAssertEqual(works, [])
        XCTAssertEqual(transport.calls, 0)
    }

    func test_decoderUsesDefaultKeys() {
        let json = Data(#"{"objectid":"1","title":"A","maker":"B"}"#.utf8)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .useDefaultKeys
        do {
            let hit = try decoder.decode(CrateHitDTO.self, from: json)
            XCTAssertEqual(hit.asWork()?.id, "1")
        } catch {
            XCTFail("decode")
        }
    }

    private func http(_ code: Int, body: Data) -> (Data, URLResponse) {
        let url = URL(string: "https://collections.frick.org/cgi/search.pl") ?? URL(fileURLWithPath: "/tmp")
        let response = HTTPURLResponse(url: url, statusCode: code, httpVersion: nil, headerFields: nil)
        return (body, response ?? URLResponse())
    }
}

/// Test double. Mutated only on the test thread that awaits client calls.
private final class StubCrateTransport: CrateTransport, @unchecked Sendable {
    enum Event {
        case success((Data, URLResponse))
        case failure(Error)
    }

    private var events: [Event]
    private(set) var calls = 0

    init(events: [Event]) {
        self.events = events
    }

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        calls += 1
        guard !events.isEmpty else {
            throw URLError(.badServerResponse)
        }
        let event = events.removeFirst()
        switch event {
        case .success(let pair):
            return pair
        case .failure(let error):
            throw error
        }
    }
}
