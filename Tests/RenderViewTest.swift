import XCTest
import SwiftUI

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
    
    func testSwiftUIRendersInWindow() throws {
        let window = UIWindow()
        window.makeKeyAndVisible()
        let rootController = UIViewController()
        window.rootViewController = rootController
        let controller = UIHostingController(rootView: SampleView())
        let view = controller.view!
        let size = view.intrinsicContentSize
        let safeOrigin = rootController.view.safeAreaLayoutGuide.layoutFrame.origin
        view.frame = .init(origin: safeOrigin, size: size)
        rootController.addChild(controller)
        rootController.view.addSubview(controller.view)
        let image = try XCTUnwrap(view.renderLayerAsBitmap())
        XCTAssertNotNil(image)
        XCTAssertEqual(image.size, .init(width: 30, height: 20))
        let png = try XCTUnwrap(image.pngData())
        let existing = try Data(
            contentsOf: folderUrl().appendingPathComponent("sampleSwiftUIView.png")
        )
        XCTAssertEqual(existing, png)
        try png.write(to: URL(fileURLWithPath: "/tmp/sampleSwiftUIView.png"))
    }
    
}
