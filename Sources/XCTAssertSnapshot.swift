import XCTest
import SwiftUI
import UniformTypeIdentifiers

public func XCTAssertSnapshot<V: View>(_ view: V, _ name: String? = nil, colorAccuracy: Float = 0.02,
                                       file: StaticString = #filePath, line: UInt = #line) throws {
    let image = try inWindowView(view) {
        $0.renderLayerAsBitmap()
    }
    let isRunningOnCI = ProcessInfo.processInfo.environment.keys.contains("CI")
    let shouldOverwriteExpected = !isRunningOnCI
    let pngData = try XCTUnwrap(image.pngData())
    let fileName = name ?? "\(V.self).png"
    let url = folderUrl(String(describing: file)).appendingPathComponent(fileName)
    if let expectedData = try? Data(contentsOf: url) {
        let expectedImage = try XCTUnwrap(UIImage(data: expectedData))
        try XCTContext.runActivity(named: "compare images") {
            let actualImage = XCTAttachment(data: pngData, uniformTypeIdentifier: UTType.png.identifier)
            actualImage.name = "actual image"
            $0.add(actualImage)
            let diff = compare(image, expectedImage)
            if diff.maxColorDifference() > colorAccuracy {
                if shouldOverwriteExpected {
                    try pngData.write(to: url)
                }
                XCTFail(
                    """
                    view did not match snapshot, overwriting expected
                    some pixels were different by \(diff.maxColorDifference() * 100)% in color
                    max allowed difference in color: \(colorAccuracy * 100)%
                    see attached `difference` image between actual and expected
                    """,
                    file: file, line: line
                )
            }
            let ciImage = diff.difference
            let diffImage = CIContext().createCGImage(ciImage, from: ciImage.extent)
            let diffAttachment = XCTAttachment(image: UIImage(cgImage: try XCTUnwrap(diffImage)))
            diffAttachment.name = "difference"
            $0.add(diffAttachment)
        }
    } else {
        if shouldOverwriteExpected {
            try XCTContext.runActivity(named: "recording missing snapshot") {
                $0.add(.init(data: pngData, uniformTypeIdentifier: UTType.png.identifier))
                try pngData.write(to: url)
            }
            XCTFail("was missing snapshot: \(fileName), now recorded", file: file, line: line)
        } else {
            XCTFail("missing snapshot: \(fileName), not recording on CI", file: file, line: line)
        }
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
