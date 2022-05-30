import UIKit

extension UIView {
    func renderFormat() -> UIGraphicsImageRendererFormat {
        let traits = UITraitCollection(traitsFrom: [
            UITraitCollection(displayGamut: .SRGB),
            UITraitCollection(displayScale: 1.0),
            UITraitCollection(activeAppearance: .active),
            UITraitCollection(userInterfaceLevel: .base),
            UITraitCollection(legibilityWeight: .regular),
            UITraitCollection(userInterfaceStyle: .light),
            UITraitCollection(preferredContentSizeCategory: .medium),
            ])
        let format = UIGraphicsImageRendererFormat(for: traits)
        format.opaque = false
        format.preferredRange = .standard
        return format
    }
    func renderer() -> UIGraphicsImageRenderer {
        UIGraphicsImageRenderer(bounds: bounds, format: renderFormat())
    }
    
    func renderLayerAsBitmap() -> UIImage {
        renderer().image {
            layer.render(in: $0.cgContext)
        }
    }
    
    func renderLayerAsPNG() -> Data {
        renderer().pngData {
            layer.render(in: $0.cgContext)
        }
    }

    func renderHierarchyAsPNG() -> Data {
        renderer().pngData { context in
            drawHierarchy(in: bounds, afterScreenUpdates: true)
        }
    }
    func renderHierarchyOnScreen() -> UIImage {
        renderer().image { context in
            drawHierarchy(in: bounds, afterScreenUpdates: true)
        }
    }
}
