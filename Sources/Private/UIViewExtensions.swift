import UIKit

extension UIView {
    func renderFormat() -> UIGraphicsImageRendererFormat {
        let traits = UITraitCollection(traitsFrom: [
            UITraitCollection(displayGamut: .SRGB),
            UITraitCollection(displayScale: 3.0),
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
        let ren = renderer()
        return ren.pngData { context in
//            layer.render(in: $0.cgContext)
//            try! ren.runDrawingActions { another in
//                drawHierarchy(in: bounds, afterScreenUpdates: true)
//            }
            drawHierarchy(in: bounds, afterScreenUpdates: true)
        }
    }

    func renderHierarchyAsPNG() -> Data {
        let ren = renderer()
        return ren.pngData { context in
//            layer.render(in: $0.cgContext)
//            try! ren.runDrawingActions { another in
//                drawHierarchy(in: bounds, afterScreenUpdates: true)
//            }
            drawHierarchy(in: bounds, afterScreenUpdates: true)
        }
    }
    func renderHierarchyOnScreen() -> UIImage {
        let ren = renderer()
        assert(ren.allowsImageOutput)
        let clazz: AnyClass = UIGraphicsImageRenderer.rendererContextClass()
        print(clazz)
        try! ren.runDrawingActions { context in
            drawHierarchy(in: bounds, afterScreenUpdates: true)
            
        }
        ren.pngData { context in
            
        }
        return ren.image { context in
            context.currentImage
            drawHierarchy(in: bounds, afterScreenUpdates: true)
        }
    }
}
