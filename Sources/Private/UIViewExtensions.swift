import UIKit

extension UITraitCollection {
    static let snapshots = UITraitCollection(traitsFrom: [
        UITraitCollection(displayGamut: .SRGB),
        UITraitCollection(displayScale: 1.0),
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
        format.preferredRange = .standard
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
        drawHierarchy(in: bounds, afterScreenUpdates: true)
    }
    
    func renderHierarchyOnScreen() -> UIImage {
        renderer().image(actions: drawHierarchyActions(_:))
    }
}
