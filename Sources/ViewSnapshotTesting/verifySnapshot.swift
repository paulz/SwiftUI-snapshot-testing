import XCTest
import SwiftUI
import UniformTypeIdentifiers
@testable import PreviewGroup

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
    let previewController = UIHostingController(rootView: view)
    XCTAssertTrue(previewController.view.intrinsicContentSize.width < 8000,
                  "view size: \(previewController.view.intrinsicContentSize) " +
                  "is too large to take snapshot", file: file, line: line)
    let viewName = name ?? "\(V.self)"
    let elements = PreviewGroupRoot.elements
    if !elements.isEmpty {
        PreviewGroupRoot.elements = []
        elements.enumerated().forEach {
            verifySnapshot($0.element, viewName + ".\($0.offset + 1)",
                           colorAccuracy:colorAccuracy,
                           file: file,
                           line: line)
        }
        return
    }
    guard let pngData = try? inWindowView(view, block: {
        $0.renderHierarchyAsPNG()
    }) else {
        XCTFail("failed to get snapshot of view")
        return
    }
    let isRunningOnCI = ProcessInfo.processInfo.environment.keys.contains("CI")
    let shouldOverwriteExpected = !isRunningOnCI
    let fileName = viewName + ".png"
    let url = folderUrl(String(describing: file)).appendingPathComponent(fileName)
    
    func writeActual(onFailure: String) {
        assertNoThrow({
            try ensureFolder(url: url)
            try pngData.write(to: url)
        }, onFailure, file: file, line: line)
    }
    
    if let expectedData = try? Data(contentsOf: url) {
        XCTContext.runActivity(named: viewName) {
            let actualImage = XCTAttachment(data: pngData, uniformTypeIdentifier: UTType.png.identifier)
            actualImage.name = "actual image"
            $0.add(actualImage)
            let diff = compare(pngData, expectedData)
            let actualDifference = diff.maxColorDifference()
            if actualDifference > colorAccuracy {
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
            if actualDifference > 0 {
                let ciImage = diff.difference.premultiplyingAlpha().adjustExposure(amount: actualDifference)
                let context = CIContext(options: [
                    .workingColorSpace : workColorSpace,
                    .allowLowPower: NSNumber(booleanLiteral: false),
                    .highQualityDownsample: NSNumber(booleanLiteral: true),
                    .outputColorSpace: workColorSpace,
                    .useSoftwareRenderer: NSNumber(booleanLiteral: true),
                    .cacheIntermediates: NSNumber(booleanLiteral: false),
                    .priorityRequestLow: NSNumber(booleanLiteral: false),
                    .name: "difference"
                ])
                let data = context.pngRepresentation(of: ciImage, format: .RGBA8, colorSpace: workColorSpace)!
                let diffAttachment = XCTAttachment(data: data, uniformTypeIdentifier: UTType.png.identifier)
                diffAttachment.name = "difference"
                $0.add(diffAttachment)
            }
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

public struct SnapshotsConfiguration {
    public var folderUrl: URL? = nil
}

public var snapshotsConfiguration = SnapshotsConfiguration()

func folderUrl(_ filePath: String = #filePath) -> URL {
    snapshotsConfiguration.folderUrl
    ??
    URL(fileURLWithPath: filePath)
        .deletingLastPathComponent()
        .appendingPathComponent("Snapshots")
}

/**
 Avoids runtime warning: *Unbalanced calls to begin/end appearance transition for UIViewController*
 
 see: https://github.com/paulz/SwiftUI-snapshot-testing/issues/11
 */
func allowAppearanceTransition() {
    RunLoop.current.run(until: .init(timeIntervalSinceNow: 0.01))
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
    view.backgroundColor = .clear
    let safeOrigin = layoutFrame.origin
    rootController.addChild(controller)
    allowAppearanceTransition()
    view.frame = .init(origin: safeOrigin, size: size)
    rootController.view.addSubview(controller.view)
    view.frame = .init(origin: safeOrigin, size: size)
    XCTAssertEqual(view.bounds.size, size)
    defer {
        view.removeFromSuperview()
        controller.removeFromParent()
        allowAppearanceTransition()
    }
    return block(view)
}
