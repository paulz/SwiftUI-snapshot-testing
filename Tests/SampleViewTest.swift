import XCTest
import UniformTypeIdentifiers
import SwiftUI_snapshot_testing

class SampleViewTest: XCTestCase {
    func testSwiftUIRendersInWindow() throws {
        let image = try inWindowView(SampleView()) {
            $0.renderLayerAsBitmap()
        }
        XCTAssertEqual(image.size, .init(width: 30, height: 20))
        let pngData = try XCTUnwrap(image.pngData())
        let expectedData = try Data(
            contentsOf: folderUrl().appendingPathComponent("sampleSwiftUIView.png")
        )
        let expectedImage = try XCTUnwrap(UIImage(data: expectedData))
        
        XCTContext.runActivity(named: "compare images") {
            $0.add(.init(data: pngData, uniformTypeIdentifier: UTType.png.identifier))
            let diff = compare(image, expectedImage)
            XCTAssertEqual(0, diff.maxColorDifference(), accuracy: 0.00002)
        }
    }
}
