import XCTest
@testable import ProgressReporter

final class ProgressReporterTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(ProgressReporter().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
