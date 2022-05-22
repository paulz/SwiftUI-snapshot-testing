import XCTest
import SwiftUI
import UniformTypeIdentifiers

public func XCTAssertSnapshot<V: View>(_ view: V, _ name: String, colorAccuracy: Float = 0.02,
                                       file: StaticString = #filePath, line: UInt = #line) throws {
    let image = try inWindowView(view) {
        $0.renderLayerAsBitmap()
    }
    let pngData = try XCTUnwrap(image.pngData())
    let expectedData = try Data(
        contentsOf: folderUrl(String(describing: file)).appendingPathComponent("sampleSwiftUIView.png")
    )
    let expectedImage = try XCTUnwrap(UIImage(data: expectedData))
    XCTContext.runActivity(named: "compare images") {
        $0.add(.init(data: pngData, uniformTypeIdentifier: UTType.png.identifier))
        let diff = compare(image, expectedImage)
        XCTAssertEqual(0, diff.maxColorDifference(), accuracy: 0.00002)
    }
}

func folderUrl(_ filePath: String = #filePath) -> URL {
    URL(fileURLWithPath: filePath)
        .deletingLastPathComponent()
        .appendingPathComponent("Snapshots")
}

func inWindowView<V: View, T>(_ swiftUIView: V, block: (UIView) -> T) throws -> T {
    let window = UIWindow()
    window.makeKeyAndVisible()
    let rootController = UIViewController()
    window.rootViewController = rootController
    let controller = UIHostingController(rootView: swiftUIView)
    let view = try XCTUnwrap(controller.view)
    let size = view.intrinsicContentSize
    let safeOrigin = rootController.view.safeAreaLayoutGuide.layoutFrame.origin
    view.frame = .init(origin: safeOrigin, size: size)
    rootController.addChild(controller)
    rootController.view.addSubview(controller.view)
    view.frame = .init(origin: safeOrigin, size: size)
    XCTAssertEqual(size, view.intrinsicContentSize)
    defer {
        view.removeFromSuperview()
        controller.removeFromParent()
    }
    return block(view)
}
