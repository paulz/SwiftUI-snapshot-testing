//

@testable import ViewSnapshotTesting
import XCTest

class CompareTest: XCTestCase {
    func testSameDataShouldHave0Difference() throws {
        let expectedData = try Data(
            contentsOf: folderUrl().appendingPathComponent("SampleView.png")
        )
        let result = compare(expectedData, expectedData)
        XCTAssertEqual(result.maxColorDifference(), 0)
    }
}
