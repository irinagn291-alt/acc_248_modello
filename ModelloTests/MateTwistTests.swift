import XCTest
@testable import Modello

final class MateTwistTests: XCTestCase {
    func test_installWritesStudyAndFourTrials() {
        var generator = CrateEntropy(seed: 7)
        let (next, outcome) = Bottega.install(WorkFixtures.crate(), generator: &generator)
        guard case .installed(let study, let trials) = outcome else {
            return XCTFail("install should hang a study")
        }
        XCTAssertEqual(trials.count, 4)
        XCTAssertEqual(Set(trials.map(\.id)).count, 4)
        let siblings = trials.filter { $0.maker == study.maker }
        XCTAssertEqual(siblings.count, 1)
        let others = trials.filter { $0.maker != study.maker }
        XCTAssertEqual(others.count, 3)
        if case .installed = next.pendant {
            XCTAssertTrue(true)
        } else {
            XCTFail("pendant should be installed")
        }
    }

    func test_secondInstallWhileInstalledIsRefused() {
        var generator = CrateEntropy(seed: 3)
        let (next, _) = Bottega.install(WorkFixtures.installed(), generator: &generator)
        XCTAssertEqual(next.pendant, WorkFixtures.installed().pendant)
    }

    func test_mateOnIdleIsRefused() {
        let (_, outcome) = Bottega.mate(trialId: "missing", in: BottegaDocument.empty)
        XCTAssertEqual(outcome, .refused)
    }

    func test_mateOnSiblingWritesTwinMark() {
        let document = WorkFixtures.installed()
        guard case .installed(let study, let trials) = document.pendant else {
            return XCTFail("need installed seed")
        }
        let sibling = trials.first { $0.maker == study.maker }
        guard let sibling else {
            return XCTFail("seed sibling missing")
        }
        let (next, outcome) = Bottega.mate(trialId: sibling.id, in: document)
        guard case .twinned(let mark) = outcome else {
            return XCTFail("mate should twin")
        }
        XCTAssertEqual(mark.studyObjectId, study.objectId)
        XCTAssertEqual(next.twinMarks.count, 1)
        if case .twinned(let filed) = next.pendant {
            XCTAssertEqual(filed.objectId, study.objectId)
        } else {
            XCTFail("should fold to twinned")
        }
        XCTAssertTrue(next.twinnedObjectIds.contains(study.objectId))
        XCTAssertFalse(Bottega.installPool(in: next).contains { $0.id == study.objectId })
    }

    func test_installWithoutSameHandPairWritesIdle() {
        var document = BottegaDocument.empty
        document.works = [
            Work(id: "a", title: "One", maker: "Alone", imageURL: ""),
            Work(id: "b", title: "Two", maker: "Other", imageURL: ""),
            Work(id: "c", title: "Three", maker: "Third", imageURL: ""),
            Work(id: "d", title: "Four", maker: "Fourth", imageURL: ""),
        ]
        var generator = CrateEntropy(seed: 1)
        let (next, outcome) = Bottega.install(document, generator: &generator)
        XCTAssertEqual(outcome, .idle)
        XCTAssertEqual(next.pendant, .idle)
    }

    func test_unknownTrialIdIsRefused() {
        let (_, outcome) = Bottega.mate(trialId: "nope", in: WorkFixtures.installed())
        XCTAssertEqual(outcome, .refused)
    }

    func test_retractPeelsNewestMark() {
        let document = WorkFixtures.installed()
        guard case .installed(_, let trials) = document.pendant else {
            return XCTFail("need trials")
        }
        let miss = trials.first { $0.maker != document.pendant.study?.maker }
        guard let miss else { return XCTFail("need miss") }
        let (broken, _) = Bottega.mate(trialId: miss.id, in: document)
        let (peeled, outcome) = Bottega.retract(broken)
        guard case .peeledBreak = outcome else {
            return XCTFail("should peel the break")
        }
        XCTAssertTrue(peeled.breakMarks.isEmpty)
    }

    func test_storeRepeatedObjectIdFocusesRow() {
        var document = BottegaDocument.empty
        let work = FrickShelf.works[0]
        document = Bottega.store(work, in: document)
        document = Bottega.store(work, in: document)
        XCTAssertEqual(document.works.count, 1)
        XCTAssertEqual(document.focusedObjectId, work.id)
    }

    func test_architectureIsOnePendantFold() {
        var generator = CrateEntropy(seed: 11)
        let (installed, installOutcome) = Bottega.install(WorkFixtures.crate(), generator: &generator)
        guard case .installed(_, let trials) = installOutcome else {
            return XCTFail("fold starts at installed")
        }
        let studyMaker = installed.pendant.study?.maker
        let sibling = trials.first { $0.maker == studyMaker }
        guard let sibling else { return XCTFail("sibling") }
        let (twinned, mateOutcome) = Bottega.mate(trialId: sibling.id, in: installed)
        guard case .twinned = mateOutcome else {
            return XCTFail("fold ends at twinned")
        }
        if case .twinned = twinned.pendant {
            XCTAssertTrue(true)
        } else {
            XCTFail("pendant ADT must be twinned")
        }
    }
}
