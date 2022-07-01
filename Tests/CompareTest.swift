@testable import ViewSnapshotTesting
import XCTest
import VisualTestKit

class CompareTest: XCTestCase {
    let imageUrl = folderUrl().appendingPathComponent("SampleView.png")

    func testVisualTestKitSnapshot() throws {
        let view = UIImageView(image: UIImage(contentsOfFile: imageUrl.path))
        let image = try XCTUnwrap(view.vtk_Snapshot() as? UIImage)
        XCTAssertEqual(image.size, CGSize(width: 30, height: 20))
    }

    func testSameDataShouldHave0Difference() throws {
        let expectedData = try Data(
            contentsOf: imageUrl
        )
        let result = compare(expectedData, expectedData)
        XCTAssertEqual(result.maxColorDifference(), 0)
    }
}
