//
//  UIView+Extensions.swift
//  Experiments
//
//  Created by Paul Zabelin on 5/11/22.
//

import UIKit

func withinBitmapContext(size: CGSize, block: (CGContext)->Void) -> UIImage? {
    UIGraphicsBeginImageContextWithOptions(size, true, UIScreen.main.scale)
    block(UIGraphicsGetCurrentContext()!)
    defer {
        UIGraphicsEndImageContext()
    }
    return UIGraphicsGetImageFromCurrentImageContext()
}

extension UIView {
    func renderLayerAsBitmap() -> UIImage? {
        withinBitmapContext(size: bounds.size) {
            layer.render(in: $0)
        }
    }
    
    func renderHierarchyOnScreen() -> UIImage {
        UIGraphicsImageRenderer(size: bounds.size).image { _ in
            drawHierarchy(in: bounds, afterScreenUpdates: true)
        }
    }
}
