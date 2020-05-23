import XCTest
@testable import ProgressReporter

final class ProgressReporterTests: XCTestCase {
    
    func testProgressValues() {
        let progress = TangibleProgress.init(completed: 3, total: 10)
        XCTAssertEqual(progress.completed, 3)
        XCTAssertEqual(progress.total, 10)
        XCTAssertEqual(progress.progress, 0.3)
    }

    func testProgressCoordinator() {
        let sharedCoordinator = ProgressCoordinator.shared
        sharedCoordinator.addStepsToProgress(additionalSteps: 10)
        XCTAssertEqual(sharedCoordinator.progress.progress, 0.0)
        for increment in 1...11 {
            sharedCoordinator.reportProgress()
            XCTAssertEqual(sharedCoordinator.progress.progress, Float(increment)/Float(sharedCoordinator.progress.total))
        }
        XCTAssertEqual(sharedCoordinator.progress.progress, 1.0)
    }
    
    static var allTests = [
        ("testProgressValues", testProgressValues),
        ("testProgressCoordinator", testProgressCoordinator)
    ]
    
}
