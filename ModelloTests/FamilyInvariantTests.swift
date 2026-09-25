import XCTest
@testable import Modello

final class FamilyInvariantTests: XCTestCase {
    func test_quizDrawsFromSavedWorks() {
        let document = WorkFixtures.installed()
        XCTAssertTrue(Bottega.quizDrawsFromSaved(document))
        XCTAssertTrue(document.canMate)
    }

    func test_missesAreReviewable() {
        let document = WorkFixtures.installed()
        guard case .installed(_, let trials) = document.pendant else {
            return XCTFail("seed must be installed")
        }
        let miss = trials.first { $0.maker != document.pendant.study?.maker }
        guard let miss else {
            return XCTFail("seed must include another maker")
        }
        let (next, outcome) = Bottega.mate(trialId: miss.id, in: document)
        guard case .broken = outcome else {
            return XCTFail("miss must file a BreakMark")
        }
        XCTAssertEqual(next.breakMarks.count, 1)
        XCTAssertTrue(Bottega.missesAreReviewable(next))
        if case .installed = next.pendant {
            XCTAssertTrue(true)
        } else {
            XCTFail("a miss keeps the Study")
        }
    }

    func test_collectingWithoutATestIsNotEnough() {
        var document = BottegaDocument.empty
        document.works = FrickShelf.works
        XCTAssertTrue(Bottega.quizDrawsFromSaved(document))
        XCTAssertFalse(document.canMate)
        XCTAssertEqual(document.pendant, .idle)
    }
}
