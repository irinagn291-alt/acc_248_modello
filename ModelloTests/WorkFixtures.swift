import Foundation
@testable import Modello

enum WorkFixtures {
    static func crate() -> BottegaDocument {
        var document = BottegaDocument.empty
        document.works = FrickShelf.works
        return document
    }

    static func installed() -> BottegaDocument {
        FrickShelf.seededDocument()
    }
}
