import UIKit
import XCTest

extension UITraitCollection {
    static let snapshots = UITraitCollection(traitsFrom: [
        UITraitCollection(displayGamut: .P3),
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
        configureContext(context)
        layer.render(in: context.cgContext)
    }
    
    func configureContext(_ context: UIGraphicsImageRendererContext) {
        context.cgContext.setFlatness(0.01)
        context.cgContext.setShouldAntialias(true)
        context.cgContext.setAllowsAntialiasing(true)
        context.cgContext.setAllowsFontSubpixelPositioning(false)
        context.cgContext.setShouldSubpixelPositionFonts(false)
        context.cgContext.setShouldSmoothFonts(false)
        context.cgContext.setAllowsFontSubpixelQuantization(false)
        context.cgContext.setShouldSubpixelQuantizeFonts(false)
    }

    func renderHierarchyAsPNG() -> Data {
        renderer().pngData(actions: drawHierarchyActions(_:))
    }
    
    func drawHierarchyActions(_ context: UIGraphicsImageRendererContext) {
//        configureContext(context)
//        print("drawHierarchyActions", self)
//        changeDelegate {
//        layer.presentation()?.render(in: context.cgContext)
//        layer.allowsGroupOpacity = true
//        layer.allowsEdgeAntialiasing = true
        context.cgContext.interpolationQuality = .high
        context.cgContext.resetClip()
//        layer.layoutSublayers()
        setNeedsLayout()
        RunLoop.current.run(until: .init(timeIntervalSinceNow: 0.01))
        setNeedsDisplay()
        RunLoop.current.run(until: .init(timeIntervalSinceNow: 0.01))
        XCTAssertNil(layer.backgroundFilters)
        XCTAssertNil(layer.filters)
        XCTAssertNil(layer.compositingFilter)
        XCTAssertNil(layer.sublayers)
//        layer.draw(in: context.cgContext)
//        layer.display()
        layer.setNeedsLayout()
        RunLoop.current.run(until: .init(timeIntervalSinceNow: 0.01))
        layer.setNeedsDisplay()
        RunLoop.current.run(until: .init(timeIntervalSinceNow: 0.01))
        let data = try! NSKeyedArchiver.archivedData(withRootObject: layer, requiringSecureCoding: false)
        print(data)
        layer.render(in: context.cgContext)
//            drawHierarchy(in: bounds, afterScreenUpdates: true)
//            XCTAssertTrue(drawHierarchy(in: bounds, afterScreenUpdates: true),
//                          "unable to take snapshot of the view")
//        }
    }
    
    func changeDelegate(block: ()->Void) {
        let previous = layer.delegate!
        let inspector = Inspector(parent: self)
        layer.delegate = inspector
        block()
        layer.delegate = previous
    }
    
    func renderHierarchyOnScreen() -> UIImage {
        renderer().image(actions: drawHierarchyActions(_:))
    }
}

class Inspector: NSObject {
    let parent: CALayerDelegate
    init(parent: CALayerDelegate) {
        self.parent = parent
        super.init()
    }
}



extension Inspector: CALayerDelegate {
    override func forwardingTarget(for aSelector: Selector!) -> Any? {
        parent
    }
//    func display(_ layer: CALayer) {
//        parent.display?(layer)
//    }
    func draw(_ layer: CALayer, in ctx: CGContext) {
        parent.draw?(layer, in: ctx)
    }
    func layerWillDraw(_ layer: CALayer) {
        parent.layerWillDraw?(layer)
    }
    func layoutSublayers(of layer: CALayer) {
        parent.layoutSublayers?(of: layer)
    }
    func action(for layer: CALayer, forKey event: String) -> CAAction? {
        parent.action?(for: layer, forKey: event)
    }
}
