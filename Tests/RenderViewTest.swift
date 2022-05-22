import XCTest
import SwiftUI
import UniformTypeIdentifiers
import SwiftUI_snapshot_testing

class RenderViewTest: XCTestCase {
    let sampleView: UIView = {
        let frame = CGRect(origin: .zero, size: CGSize(width: 40, height: 20))
        let view = UIView(frame: frame)        
        view.backgroundColor = .darkGray
        let label = UILabel(frame: frame)
        label.text = "Hello"
        label.textColor = .yellow
        view.addSubview(label)
        return view
    }()
    
    func testRenderLayer() throws {
        let image = try XCTUnwrap(sampleView.renderLayerAsBitmap())
        XCTAssertNotNil(image)
        XCTAssertEqual(image.size, .init(width: 40, height: 20))
        let png = try XCTUnwrap(image.pngData())
        let existing = try Data(
            contentsOf: folderUrl().appendingPathComponent("sampleView.png")
        )
        XCTAssertEqual(existing, png)
        try png.write(to: URL(fileURLWithPath: "/tmp/sampleView.png"))
    }
}
