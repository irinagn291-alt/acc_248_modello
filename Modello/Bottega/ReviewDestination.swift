import Foundation

/// Role: launch-key parser. These strings are not tabs.
enum ReviewDestination: String, Sendable, Equatable {
    case today
    case log
    case goals
    case explore
    case saved
    case exploresheet
    case savedsheet
    case settingssheet
    case twist

    static func parse(arguments: [String]) -> ReviewDestination? {
        guard let index = arguments.firstIndex(of: "-ReviewScreen") else {
            return nil
        }
        let next = arguments.index(after: index)
        guard next < arguments.endIndex else { return nil }
        return ReviewDestination(rawValue: arguments[next])
    }

    /// Read once after onboarding. today|log|goals are launch keys, not tabs.
    static func parseLaunch(info: ProcessInfo = .processInfo) -> ReviewDestination? {
        parse(arguments: info.arguments)
    }
}
