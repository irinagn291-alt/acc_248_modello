import XCTest
@testable import Modello

final class ReviewDestinationTests: XCTestCase {
    func test_parsesTodayLogGoalsAndExplore() {
        XCTAssertEqual(ReviewDestination.parse(arguments: ["-ReviewScreen", "today"]), .today)
        XCTAssertEqual(ReviewDestination.parse(arguments: ["-ReviewScreen", "log"]), .log)
        XCTAssertEqual(ReviewDestination.parse(arguments: ["-ReviewScreen", "goals"]), .goals)
        XCTAssertEqual(ReviewDestination.parse(arguments: ["-ReviewScreen", "explore"]), .explore)
        XCTAssertEqual(ReviewDestination.parse(arguments: ["-ReviewScreen", "saved"]), .saved)
        XCTAssertEqual(ReviewDestination.parse(arguments: ["-ReviewScreen", "exploresheet"]), .exploresheet)
        XCTAssertEqual(ReviewDestination.parse(arguments: ["-ReviewScreen", "savedsheet"]), .savedsheet)
        XCTAssertEqual(ReviewDestination.parse(arguments: ["-ReviewScreen", "settingssheet"]), .settingssheet)
        XCTAssertEqual(ReviewDestination.parse(arguments: ["-ReviewScreen", "twist"]), .twist)
    }

    func test_unknownOrMissingIsNil() {
        XCTAssertNil(ReviewDestination.parse(arguments: []))
        XCTAssertNil(ReviewDestination.parse(arguments: ["-ReviewScreen"]))
        XCTAssertNil(ReviewDestination.parse(arguments: ["-ReviewScreen", "shop"]))
    }

    func test_parseLaunchReadsProcessInfo() {
        let fromInfo = ReviewDestination.parse(arguments: ProcessInfo.processInfo.arguments)
        XCTAssertEqual(ReviewDestination.parseLaunch(), fromInfo)
    }
}
