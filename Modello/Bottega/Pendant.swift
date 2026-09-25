import Foundation

/// Role: the pendant ADT. The bottega is a fold over Works into this case.
enum Pendant: Hashable, Sendable, Codable, Equatable {
    case idle
    case installed(Study, [Trial])
    case twinned(Study)

    var study: Study? {
        switch self {
        case .idle:
            return nil
        case .installed(let study, _), .twinned(let study):
            return study
        }
    }

    var trials: [Trial] {
        if case .installed(_, let trials) = self {
            return trials
        }
        return []
    }

    var quizCards: [QuizCard] { trials }
}
