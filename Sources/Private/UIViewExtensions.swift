import UIKit

extension UIView {
    func renderFormat() -> UIGraphicsImageRendererFormat {
        let format = UIGraphicsImageRendererFormat(for: .current)
        format.opaque = false
        format.preferredRange = .extended
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

    
    func renderHierarchyOnScreen() -> UIImage {
        renderer().image { _ in
            drawHierarchy(in: bounds, afterScreenUpdates: true)
        }
    }
}
