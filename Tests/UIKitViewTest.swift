import XCTest
import SwiftUI
import UniformTypeIdentifiers
@testable import ViewSnapshotTesting

class UIKitViewTest: XCTestCase {
    let expectedSize = CGSize(width: 40, height: 20)
    
    lazy var sampleView: UIView = {
        let frame = CGRect(origin: .zero, size: expectedSize)
        let view = UIView(frame: frame)        
        view.backgroundColor = .darkGray
        let label = UILabel(frame: frame)
        label.text = "Hello"
        label.textColor = .yellow
        view.addSubview(label)
        return view
    }()
    
    func testRenderLayerAsBitmapProducesSameData() throws {
        let image = sampleView.renderLayerAsBitmap()
        XCTAssertEqual(image.size, expectedSize)
        let pngData = try XCTUnwrap(image.pngData())
        let url = folderUrl().appendingPathComponent("UIKit-sample-view.png")
        let existing = try Data(contentsOf: url)
        try XCTContext.runActivity(named: "compare image data") {
            $0.add(.init(data: pngData, uniformTypeIdentifier: UTType.png.identifier))
            if existing != pngData {
                try pngData.write(to: url)
            }
            XCTAssertEqual(existing, pngData)
        }
    }
}
