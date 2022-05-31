import UIKit
import XCTest

extension UITraitCollection {
    static let snapshots = UITraitCollection(traitsFrom: [
        UITraitCollection(displayGamut: .P3),
        UITraitCollection(displayScale: 3.0),
        UITraitCollection(activeAppearance: .active),
        UITraitCollection(userInterfaceLevel: .base),
        UITraitCollection(legibilityWeight: .regular),
        UITraitCollection(userInterfaceStyle: .light),
        UITraitCollection(preferredContentSizeCategory: .medium),
    ])
}

extension UIGraphicsImageRendererFormat {
    static let snapshots: UIGraphicsImageRendererFormat = {
        let format = UIGraphicsImageRendererFormat(for: .snapshots)
        format.opaque = false
        format.preferredRange = .extended
        return format
    }()
}

extension UIView {
    func renderer() -> UIGraphicsImageRenderer {
        UIGraphicsImageRenderer(bounds: bounds, format: .snapshots)
    }
    
    func renderLayerAsBitmap() -> UIImage {
        renderer().image(actions: renderLayerActions(_:))
    }
    
    func renderLayerAsPNG() -> Data {
        renderer().pngData(actions: renderLayerActions(_:))
    }
    
    func renderLayerActions(_ context: UIGraphicsImageRendererContext) {
        layer.render(in: context.cgContext)
    }

    func renderHierarchyAsPNG() -> Data {
        renderer().pngData(actions: drawHierarchyActions(_:))
    }
    
    func drawHierarchyActions(_ context: UIGraphicsImageRendererContext) {
        context.cgContext.setFlatness(0.1)
        context.cgContext.setShouldAntialias(true)
        context.cgContext.setAllowsAntialiasing(true)
        XCTAssertTrue(drawHierarchy(in: bounds, afterScreenUpdates: true),
                      "unable to take snapshot of the view")
    }
    
    func renderHierarchyOnScreen() -> UIImage {
        renderer().image(actions: drawHierarchyActions(_:))
    }
}
