import XCTest
import UniformTypeIdentifiers
@testable import ViewSnapshotTesting
import SwiftUI

class SampleViewTest: XCTestCase {
    let expectedSize = CGSize(width: 30, height: 20)

    func testSwiftUIRendersInWindow() {
        verifySnapshot(SampleView(), "SampleView-blank", colorAccuracy: 0)
    }
    
    func testImageSizeIsScaledFromExpected() throws {
        let image = try inWindowView(SampleView()) {
            $0.renderLayerAsBitmap()
        }
        let url = folderUrl().appendingPathComponent("SampleView.png")
        XCTAssertEqual(image.size, expectedSize)
        let expectedData = try Data(contentsOf: url)
        let expectedImage = try XCTUnwrap(UIImage(data: expectedData, scale: 1))
        let result = compare(image, expectedImage)
        let colorDifference = result.maxColorDifference()
        if colorDifference > 0 {
            try image.pngData()?.write(to: url)
        }
        XCTAssertEqual(colorDifference, 0)
        XCTAssertEqual(expectedImage.size, expectedSize)
    }
}
