import Foundation

/// Role: JSON that mirrors cgi/search.pl. Never decode straight into Work.
struct CrateSearchDTO: Decodable, Sendable {
    var status: Int?
    var page: Int?
    var count: Int?
    var hits: [CrateHitDTO]?
    var products: [CrateHitDTO]?

    var rows: [CrateHitDTO] {
        if let hits, !hits.isEmpty { return hits }
        return products ?? []
    }
}

struct CrateHitDTO: Decodable, Sendable {
    var objectid: String?
    var code: String?
    var title: String?
    var product_name: String?
    var maker: String?
    var brands: String?
    var image_url: String?
    var image_small_url: String?

    func asWork() -> Work? {
        let id = firstNonEmpty(objectid, code)
        let title = firstNonEmpty(title, product_name)
        let maker = firstNonEmpty(maker, brands)
        guard let id, let title, let maker else { return nil }
        let image = firstNonEmpty(image_url, image_small_url) ?? ""
        return Work(id: id, title: title, maker: maker, imageURL: image)
    }

    private func firstNonEmpty(_ values: String?...) -> String? {
        for value in values {
            if let value {
                let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
                if !trimmed.isEmpty { return trimmed }
            }
        }
        return nil
    }
}

struct CrateResolveDTO: Decodable, Sendable {
    var status: Int?
    var hit: CrateHitDTO?
    var product: CrateHitDTO?
}
