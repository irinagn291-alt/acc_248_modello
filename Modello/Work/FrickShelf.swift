import Foundation

/// Role: bundled Frick Collection shelf when search is empty or fails.
enum FrickShelf {
    static let creditName = "The Frick Collection"
    static let creditURL = URL(string: "https://www.frick.org/collection")

    static let works: [Work] = [
        Work(
            id: "1915.1.03",
            title: "Saint Francis in the Desert",
            maker: "Giovanni Bellini",
            imageURL: "https://collections.frick.org/media/1915.1.03.jpg"
        ),
        Work(
            id: "1915.1.21",
            title: "Saint Dominic",
            maker: "Giovanni Bellini",
            imageURL: "https://collections.frick.org/media/1915.1.21.jpg"
        ),
        Work(
            id: "1915.1.31",
            title: "Sir Thomas More",
            maker: "Hans Holbein the Younger",
            imageURL: "https://collections.frick.org/media/1915.1.31.jpg"
        ),
        Work(
            id: "1915.1.32",
            title: "Thomas Cromwell",
            maker: "Hans Holbein the Younger",
            imageURL: "https://collections.frick.org/media/1915.1.32.jpg"
        ),
        Work(
            id: "1911.1.127",
            title: "Officer and Laughing Girl",
            maker: "Johannes Vermeer",
            imageURL: "https://collections.frick.org/media/1911.1.127.jpg"
        ),
        Work(
            id: "1927.1.81",
            title: "Comtesse d Haussonville",
            maker: "Jean-Auguste-Dominique Ingres",
            imageURL: "https://collections.frick.org/media/1927.1.81.jpg"
        ),
        Work(
            id: "1915.1.115",
            title: "Portrait of a Man in a Red Cap",
            maker: "Titian",
            imageURL: "https://collections.frick.org/media/1915.1.115.jpg"
        ),
        Work(
            id: "1914.1.47",
            title: "The Forge",
            maker: "Francisco de Goya",
            imageURL: "https://collections.frick.org/media/1914.1.47.jpg"
        ),
    ]

    static func seededDocument() -> BottegaDocument {
        let studyWork = works[0]
        let sibling = works[1]
        let decoys = Array(works[2...4])
        let trials = ([sibling] + decoys).map { Trial(id: $0.id, work: $0, cooled: false) }
        return BottegaDocument(
            schemaVersion: BottegaDocument.currentSchema,
            works: works,
            pendant: .installed(Study(work: studyWork), trials),
            twinMarks: [],
            breakMarks: [],
            catalogCache: works,
            focusedObjectId: studyWork.id,
            onboardingComplete: true,
            nextSeq: 1,
            loadNotice: nil
        )
    }
}
