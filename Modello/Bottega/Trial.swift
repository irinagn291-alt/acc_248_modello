import Foundation

/// Role: one unlabeled tile on the Quiz rail. This is the app's quiz card.
struct Trial: Identifiable, Hashable, Sendable, Codable, Equatable {
    var id: String
    var work: Work
    var cooled: Bool

    var maker: String { work.maker }
}

typealias QuizCard = Trial
