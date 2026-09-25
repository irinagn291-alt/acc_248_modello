import Foundation

/// Role: owns the in-flight Explore search. A new query cancels the last task.
@MainActor
final class CrateSearch {
    private var task: Task<[Work], Never>?

    func submit(
        query: String,
        client: CrateClient,
        cached: [Work],
        debounceNanos: UInt64 = 300_000_000
    ) async -> [Work] {
        task?.cancel()
        let work = Task<[Work], Never> {
            do {
                try await Task.sleep(nanoseconds: debounceNanos)
            } catch {
                return []
            }
            if Task.isCancelled { return [] }
            return await client.browse(query: query, cached: cached)
        }
        task = work
        return await work.value
    }

    func cancel() {
        task?.cancel()
        task = nil
    }
}
