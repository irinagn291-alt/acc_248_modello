import Foundation

enum InstallOutcome: Equatable, Sendable {
    case installed(Study, [Trial])
    case idle
    case refused
}

enum MateOutcome: Equatable, Sendable {
    case twinned(TwinMark)
    case broken(BreakMark)
    case refused
}

enum RetractOutcome: Equatable, Sendable {
    case peeledTwin(TwinMark)
    case peeledBreak(BreakMark)
    case refused
}

/// Seeded generator so install sampling is testable.
struct CrateEntropy: RandomNumberGenerator, Sendable {
    private var state: UInt64

    init(seed: UInt64) {
        self.state = seed == 0 ? 0x9E3779B97F4A7C15 : seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1
        return state
    }
}

/// Role: the bottega fold. Install writes a Study and four Trials; Mate files marks.
enum Bottega {
    static func installPool(in document: BottegaDocument) -> [Work] {
        let taken = document.twinnedObjectIds
        return document.works.filter { work in
            !taken.contains(work.id) && hasSameHandSibling(work, in: document.works, excluding: taken)
        }
    }

    static func hasSameHandSibling(_ work: Work, in works: [Work], excluding taken: Set<String>) -> Bool {
        works.contains { other in
            other.id != work.id
                && other.maker == work.maker
                && !taken.contains(other.id)
        }
    }

    static func install(
        _ document: BottegaDocument,
        generator: inout CrateEntropy
    ) -> (BottegaDocument, InstallOutcome) {
        if case .installed = document.pendant {
            return (document, .refused)
        }
        var pool = installPool(in: document)
        guard !pool.isEmpty else {
            var next = document
            next.pendant = .idle
            return (next, .idle)
        }
        pool.shuffle(using: &generator)
        guard let studyWork = pool.first else {
            var next = document
            next.pendant = .idle
            return (next, .idle)
        }
        let taken = document.twinnedObjectIds
        let siblingCandidates = document.works.filter { other in
            other.id != studyWork.id
                && other.maker == studyWork.maker
                && !taken.contains(other.id)
        }
        guard let sibling = siblingCandidates.randomElement(using: &generator) else {
            var next = document
            next.pendant = .idle
            return (next, .idle)
        }
        var others = document.works.filter { other in
            other.id != studyWork.id
                && other.id != sibling.id
                && other.maker != studyWork.maker
                && !taken.contains(other.id)
        }
        others.shuffle(using: &generator)
        let decoys = Array(others.prefix(3))
        guard decoys.count == 3 else {
            var next = document
            next.pendant = .idle
            return (next, .idle)
        }
        var rail = [sibling] + decoys
        rail.shuffle(using: &generator)
        let trials = rail.map { Trial(id: $0.id, work: $0, cooled: false) }
        let study = Study(work: studyWork)
        var next = document
        next.pendant = .installed(study, trials)
        return (next, .installed(study, trials))
    }

    static func mate(
        trialId: String,
        in document: BottegaDocument,
        now: Date = Date(),
        calendar: Calendar = .current
    ) -> (BottegaDocument, MateOutcome) {
        guard case .installed(let study, var trials) = document.pendant else {
            return (document, .refused)
        }
        guard let index = trials.firstIndex(where: { $0.id == trialId }) else {
            return (document, .refused)
        }
        let trial = trials[index]
        let dayKey = DayEdge.key(on: now, calendar: calendar)
        if trial.maker == study.maker {
            let mark = TwinMark(
                id: "twin-\(document.nextSeq)",
                studyObjectId: study.objectId,
                trialObjectId: trial.work.id,
                dayKey: dayKey,
                seq: document.nextSeq
            )
            var next = document
            next.twinMarks.append(mark)
            next.nextSeq += 1
            next.pendant = .twinned(study)
            next.focusedObjectId = study.objectId
            return (next, .twinned(mark))
        }
        trials[index].cooled = true
        let mark = BreakMark(
            id: "break-\(document.nextSeq)",
            studyObjectId: study.objectId,
            trialObjectId: trial.work.id,
            dayKey: dayKey,
            seq: document.nextSeq
        )
        var next = document
        next.breakMarks.append(mark)
        next.nextSeq += 1
        next.pendant = .installed(study, trials)
        return (next, .broken(mark))
    }

    static func retract(_ document: BottegaDocument) -> (BottegaDocument, RetractOutcome) {
        let lastTwin = document.twinMarks.max(by: { $0.seq < $1.seq })
        let lastBreak = document.breakMarks.max(by: { $0.seq < $1.seq })
        switch (lastTwin, lastBreak) {
        case (let twin?, let brk?) where twin.seq > brk.seq:
            return peelTwin(twin, from: document)
        case (let twin?, nil):
            return peelTwin(twin, from: document)
        case (_, let brk?):
            return peelBreak(brk, from: document)
        default:
            return (document, .refused)
        }
    }

    static func store(_ work: Work, in document: BottegaDocument) -> BottegaDocument {
        var next = document
        if let existing = next.works.firstIndex(where: { $0.id == work.id }) {
            next.works[existing] = work
            next.focusedObjectId = work.id
            return next
        }
        next.works.append(work)
        next.focusedObjectId = work.id
        if !next.catalogCache.contains(where: { $0.id == work.id }) {
            next.catalogCache.append(work)
        }
        return next
    }

    static func rememberCatalog(_ works: [Work], in document: BottegaDocument) -> BottegaDocument {
        var next = document
        for work in works {
            if let index = next.catalogCache.firstIndex(where: { $0.id == work.id }) {
                next.catalogCache[index] = work
            } else {
                next.catalogCache.append(work)
            }
        }
        return next
    }

    static func quizDrawsFromSaved(_ document: BottegaDocument) -> Bool {
        switch document.pendant {
        case .idle:
            return true
        case .installed(let study, let trials):
            let saved = Set(document.works.map(\.id))
            return saved.contains(study.objectId) && trials.allSatisfy { saved.contains($0.work.id) }
        case .twinned(let study):
            return document.works.contains { $0.id == study.objectId }
        }
    }

    static func missesAreReviewable(_ document: BottegaDocument) -> Bool {
        document.breakMarks.allSatisfy { mark in
            document.works.contains { $0.id == mark.studyObjectId }
                || document.pendant.study?.objectId == mark.studyObjectId
        }
    }

    private static func peelTwin(_ mark: TwinMark, from document: BottegaDocument) -> (BottegaDocument, RetractOutcome) {
        var next = document
        next.twinMarks.removeAll { $0.id == mark.id }
        if case .twinned(let study) = next.pendant, study.objectId == mark.studyObjectId {
            next.pendant = .idle
        }
        return (next, .peeledTwin(mark))
    }

    private static func peelBreak(_ mark: BreakMark, from document: BottegaDocument) -> (BottegaDocument, RetractOutcome) {
        var next = document
        next.breakMarks.removeAll { $0.id == mark.id }
        if case .installed(let study, var trials) = next.pendant, study.objectId == mark.studyObjectId {
            if let index = trials.firstIndex(where: { $0.work.id == mark.trialObjectId }) {
                trials[index].cooled = false
                next.pendant = .installed(study, trials)
            }
        }
        return (next, .peeledBreak(mark))
    }
}
