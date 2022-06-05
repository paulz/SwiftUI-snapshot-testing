import XCTest
import UniformTypeIdentifiers
@testable import ViewSnapshotTesting
import SwiftUI

class SampleViewTest: XCTestCase {
    let expectedSize = CGSize(width: 30, height: 20)

    func testSwiftUIRendersInWindow() {
        let options = XCTExpectedFailure.Options()
        options.issueMatcher = { issue in
            issue.type == .assertionFailure &&
            issue.compactDescription.hasSuffix("unable to take snapshot of the view")
        }
        XCTExpectFailure("Unable to render SwiftUI view hierarchy",
                         options: options)
        // xctest warning:
        // [Snapshotting] Rendering a view that has not been committed to render server is not supported.
        verifySnapshot(SampleView(), "SampleView-blank", colorAccuracy: 0)
    }
    
    func testImageSizeIsScaledFromExpected() throws {
        let image = try inWindowView(SampleView()) {
            $0.renderLayerAsBitmap()
        }
        let url = folderUrl().appendingPathComponent("SampleView.png")
        XCTAssertEqual(image.size, expectedSize)
        let expectedData = try Data(contentsOf: url)
        let scale = UITraitCollection.snapshots.displayScale
        let expectedImage = try XCTUnwrap(UIImage(data: expectedData, scale: scale))
        let result = compare(image, expectedImage)
        let colorDifference = result.maxColorDifference()
        if colorDifference > 0 {
            try image.pngData()?.write(to: url)
        }
        XCTAssertEqual(colorDifference, 0)
        XCTAssertEqual(expectedImage.size, expectedSize.applying(.init(scaleX: scale, y: scale)))
    }
}
