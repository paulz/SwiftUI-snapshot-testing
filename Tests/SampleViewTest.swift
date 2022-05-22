import XCTest
import UniformTypeIdentifiers
@testable import SwiftUI_snapshot_testing
import SwiftUI

class SampleViewTest: XCTestCase {
    let expectedSize = CGSize(width: 30, height: 20)

    func testSwiftUIRendersInWindow() {
        verifySnapshot(SampleView())
    }
    
    func testImageSizeIsScaledFromExpected() throws {
        let image = try inWindowView(SampleView()) {
            $0.renderLayerAsBitmap()
        }
        XCTAssertEqual(image.size, expectedSize)
        let expectedData = try Data(
            contentsOf: folderUrl().appendingPathComponent("SampleView.png")
        )
        let expectedImage = try XCTUnwrap(UIImage(data: expectedData))
        let scale = UIScreen.main.scale
        XCTAssertEqual(expectedImage.size, expectedSize.applying(.init(scaleX: scale, y: scale)))
    }
}
