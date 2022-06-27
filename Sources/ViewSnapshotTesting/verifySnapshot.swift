import XCTest
import SwiftUI
import UniformTypeIdentifiers
@testable import PreviewGroup
import HRCoder

public func verifySnapshot<P>(_ preview: P.Type = P.self,
                              _ name: String? = nil,
                              colorAccuracy: Float = snapshotsConfiguration.colorAccuracy,
                              file: StaticString = #filePath,
                              line: UInt = #line) where P: PreviewProvider {
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

func viewNameWithoutModifiers<V>(type: V.Type = V.self) -> String {
    "\(type)"
        .components(separatedBy: ",").first!
        .components(separatedBy: "<").last!
        .trimmingCharacters(in: .punctuationCharacters)
        .trimmingCharacters(in: .symbols)
}

public func verifySnapshot<V: View>(_ view: V,
                                    _ name: String? = nil,
                                    colorAccuracy: Float = snapshotsConfiguration.colorAccuracy,
                                    file: StaticString = #filePath,
                                    line: UInt = #line) {
    let previewController = UIHostingController(rootView: view)
    XCTAssertTrue(previewController.view.intrinsicContentSize.width < 8000,
                  "view size: \(previewController.view.intrinsicContentSize) " +
                  "is too large to take snapshot", file: file, line: line)
    let viewName = name ?? viewNameWithoutModifiers(type: V.self)
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
    var layer: CALayer = .init()
    guard let pngData = try? inWindowView(view, block: { (uiView: UIView) -> Data in
        let png = uiView.renderHierarchyAsPNG()
        layer = uiView.layer
        return png
    }) else {
        XCTFail("failed to get snapshot of view")
        return
    }
    func getHumanJson() throws -> NSDictionary {
        try XCTUnwrap(
            HRCoder.archivedJSON(
                withRootObject: layer
            ) as? NSDictionary
        )
    }
    
    func getHumanJsonData() throws -> Data {
        try JSONSerialization.data(
            withJSONObject: getHumanJson(),
            options: [.prettyPrinted, .sortedKeys]
        )
    }

    let isRunningOnCI = ProcessInfo.processInfo.environment.keys.contains("CI")
    let shouldOverwriteExpected = !isRunningOnCI
    let fileName = viewName + ".png"
    let folderUrl = folderUrl(String(describing: file))
    
    let snapshotUrl = folderUrl.appendingPathComponent(fileName)
    if snapshotsConfiguration.useLayers {
        let layerFolderUrl = folderUrl.appendingPathComponent(".layers")
        let layerFileName = viewName + ".json"
        let layerJsonUrl = layerFolderUrl.appendingPathComponent(layerFileName)
        let actualJsonData = try! getHumanJsonData()
        
        func writeActualLayer(onFailure: String) {
            assertNoThrow({
                try ensureFolder(url: layerJsonUrl)
                try actualJsonData.write(to: layerJsonUrl)
            }, onFailure, file: file, line: line)
        }

        if let expectedLayerData = try? Data(contentsOf: layerJsonUrl) {
            XCTContext.runActivity(named: viewName + " layers") {
                if expectedLayerData != actualJsonData {
                    XCTFail(
                        """
                        view layer did not match snapshot: \(viewName)
                        see attached `layer` JSON representation
                        """,
                        file: file, line: line
                    )
                    let layerAttachment = XCTAttachment(data: actualJsonData, uniformTypeIdentifier: UTType.json.identifier)
                    layerAttachment.name = "layer"
                    $0.add(layerAttachment)
                    if shouldOverwriteExpected {
                        writeActual(onFailure: "failed to record actual snapshot image")
                        writeActualLayer(onFailure: "failed to record view layers")
                    }
                }
            }
        } else {
            if shouldOverwriteExpected {
                XCTContext.runActivity(named: "recording missing layer") {
                    $0.add(.init(data: actualJsonData, uniformTypeIdentifier: UTType.json.identifier))
                    writeActualLayer(onFailure: "failed to record missing layer")
                }
                XCTFail("was missing layer: \(layerFileName), now recorded at: \(layerJsonUrl.path)", file: file, line: line)
            } else {
                XCTFail("missing layer: \(layerFileName), not recording on CI", file: file, line: line)
            }
        }
    }

    func writeActual(onFailure: String) {
        assertNoThrow({
            try ensureFolder(url: snapshotUrl)
            try pngData.write(to: snapshotUrl)
        }, onFailure, file: file, line: line)
    }
    
    if let expectedData = try? Data(contentsOf: snapshotUrl) {
        XCTContext.runActivity(named: viewName) {
            let actualImage = XCTAttachment(data: pngData, uniformTypeIdentifier: UTType.png.identifier)
            actualImage.name = "actual image"
            $0.add(actualImage)
            let diff = compare(pngData, expectedData)
            let actualDifference = diff.maxColorDifference()
            if actualDifference > colorAccuracy, snapshotsConfiguration.useLayers == false {
                if shouldOverwriteExpected {
                    writeActual(onFailure: "failed to record actual image")
                }
                XCTFail(
                    """
                    view did not match snapshot: \(viewName)
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
            XCTFail("was missing snapshot: \(fileName), now recorded at: \(snapshotUrl.path)", file: file, line: line)
        } else {
            XCTFail("missing snapshot: \(fileName), not recording on CI", file: file, line: line)
        }
    }
}

func folderUrl(_ filePath: String = #filePath) -> URL {
    snapshotsConfiguration.folderUrl
    ??
    URL(fileURLWithPath: filePath)
        .deletingLastPathComponent()
        .appendingPathComponent(snapshotsConfiguration.folderName)
}

/**
 Avoids runtime warning: *Unbalanced calls to begin/end appearance transition for UIViewController*
 
 see: https://github.com/paulz/SwiftUI-snapshot-testing/issues/11
 */
func allowAppearanceTransition() {
    RunLoop.current.run(until: .init(timeIntervalSinceNow: 0.01))
}

func inWindowView<T>(_ controller: UIViewController, block: (UIView) throws -> T) throws -> T {
    let window = UIWindow()
    window.makeKeyAndVisible()
    let rootController = UIViewController()
    window.rootViewController = rootController
    allowAppearanceTransition()

    let view = try XCTUnwrap(controller.view)
    
    let layoutFrame = rootController.view.safeAreaLayoutGuide.layoutFrame
    var size = view.intrinsicContentSize
    if size == .zero || size == .init(width: -1, height: -1) {
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
    return try block(view)
}

func inWindowView<V: View, T>(_ swiftUIView: V, block: (UIView) throws -> T) throws -> T {
    try inWindowView(UIHostingController(rootView: swiftUIView), block: block)
}
