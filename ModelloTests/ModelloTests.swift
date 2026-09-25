import XCTest
@testable import Modello

final class ModelloTests: XCTestCase {
    func test_appModuleImports() {
        XCTAssertEqual(String(describing: ModelloApp.self), "ModelloApp")
    }
}
