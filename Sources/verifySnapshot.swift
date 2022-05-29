import XCTest
import SwiftUI
import UniformTypeIdentifiers

public func verifySnapshot<P>(_ preview: P.Type = P.self, _ name: String? = nil, colorAccuracy: Float = 0.02,
                              file: StaticString = #filePath, line: UInt = #line) where P: PreviewProvider {
    var name = name ?? "\(P.self)"
    let commonPreviewSuffix = "_Previews"
    if name.hasSuffix(commonPreviewSuffix) {
        name.removeLast(commonPreviewSuffix.count)
    }
    verifySnapshot(preview.previews, name, colorAccuracy: colorAccuracy, file: file, line: line)
}

@discardableResult
func assertNoThrow<T>(_ expression: () throws -> T, _ message: @autoclosure () -> String = "", file: StaticString = #filePath, line: UInt = #line) -> T? {
    do {
        return try expression()
    } catch {
        XCTFail(message() + ", due to \(error)")
    }
    return nil
}

func ensureFolder(url: URL) throws {
    try FileManager.default
        .createDirectory(at: url.deletingLastPathComponent(),
                         withIntermediateDirectories: true)
}

public func verifySnapshot<V: View>(_ view: V, _ name: String? = nil, colorAccuracy: Float = 0.02,
                                       file: StaticString = #filePath, line: UInt = #line) {
    guard let image = try? inWindowView(view, block: {
        $0.renderLayerAsBitmap()
    }) else {
        XCTFail("failed to get snapshot of view")
        return
    }
    let isRunningOnCI = ProcessInfo.processInfo.environment.keys.contains("CI")
    let shouldOverwriteExpected = !isRunningOnCI
    guard let pngData = image.pngData() else {
        XCTFail("failed to get image data")
        return
    }
    let viewName = name ?? "\(V.self)"
    let fileName = viewName + ".png"
    let url = folderUrl(String(describing: file)).appendingPathComponent(fileName)
    
    func writeActual(onFailure: String) {
        assertNoThrow({
            try ensureFolder(url: url)
            try pngData.write(to: url)
        }, onFailure, file: file, line: line)
    }
    
    if let expectedData = try? Data(contentsOf: url), let expectedImage = UIImage(data: expectedData) {
        XCTContext.runActivity(named: viewName) {
            let actualImage = XCTAttachment(data: pngData, uniformTypeIdentifier: UTType.png.identifier)
            actualImage.name = "actual image"
            $0.add(actualImage)
            let diff = compare(image, expectedImage)
            if diff.maxColorDifference() > colorAccuracy {
                if shouldOverwriteExpected {
                    writeActual(onFailure: "failed to record actual image")
                }
                XCTFail(
                    """
                    view did not match snapshot
                    some pixels were different by \(diff.maxColorDifference() * 100)% in color
                    max allowed difference in color: \(colorAccuracy * 100)%
                    see attached `difference` image between actual and expected
                    """,
                    file: file, line: line
                )
            }
            let ciImage = diff.difference
            guard let diffImage = CIContext().createCGImage(ciImage, from: ciImage.extent) else {
                XCTFail("failed to get image of difference")
                return
            }
            let diffAttachment = XCTAttachment(image: UIImage(cgImage: diffImage))
            diffAttachment.name = "difference"
            $0.add(diffAttachment)
        }
    } else {
        if shouldOverwriteExpected {
            XCTContext.runActivity(named: "recording missing snapshot") {
                $0.add(.init(data: pngData, uniformTypeIdentifier: UTType.png.identifier))
                writeActual(onFailure: "failed to record missing snapshot")
            }
            XCTFail("was missing snapshot: \(fileName), now recorded at: \(url.path)", file: file, line: line)
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

/**
 Avoids runtime warning: *Unbalanced calls to begin/end appearance transition for UIViewController*
 
 see: https://github.com/paulz/SwiftUI-snapshot-testing/issues/11
 */
func allowAppearanceTransition() {
    RunLoop.current.run(until: .init(timeIntervalSinceNow: 0))
}

func inWindowView<V: View, T>(_ swiftUIView: V, block: (UIView) -> T) throws -> T {
//    let window = UIApplication.shared.value(forKey: "keyWindow") as! UIWindow
//    let rootController = window.rootViewController!

    let window = UIWindow()
    window.makeKeyAndVisible()
    let rootController = UIViewController()
    window.rootViewController = rootController

    allowAppearanceTransition()
    let controller = UIHostingController(rootView: swiftUIView)
    let view = try XCTUnwrap(controller.view)
    let layoutFrame = rootController.view.safeAreaLayoutGuide.layoutFrame
    var size = view.intrinsicContentSize
    if size == .zero {
        size = layoutFrame.size
    }
    let safeOrigin = layoutFrame.origin
    rootController.addChild(controller)
    view.frame = .init(origin: safeOrigin, size: size)
    rootController.view.addSubview(controller.view)
    view.frame = .init(origin: safeOrigin, size: size)
    XCTAssertEqual(view.bounds.size, size)
    defer {
        view.removeFromSuperview()
        controller.removeFromParent()
    }
    return block(view)
}
