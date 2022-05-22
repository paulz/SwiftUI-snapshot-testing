import XCTest
import SwiftUI

extension XCTestCase {
    func folderUrl(_ filePath: String = #filePath) -> URL {
        URL(fileURLWithPath: filePath)
            .deletingLastPathComponent()
            .appendingPathComponent("Snapshots")
    }
    var scalePointsToDevice: CGAffineTransform {
        CGAffineTransform(scaleX: UIScreen.main.scale, y: UIScreen.main.scale)
    }
    var scaleDeviceToPoints: CGAffineTransform {
        scalePointsToDevice.inverted()
    }
    
    func onScreenView<V: View, T>(_ swiftUIView: V, block: (UIView) -> T) throws -> T {
        let window = try XCTUnwrap(UIApplication.shared.appKeyWindow)
        let rootViewController = try XCTUnwrap(window.rootViewController)
        let controller = UIHostingController(rootView: swiftUIView)
        let size = controller.view.intrinsicContentSize
        let view = try XCTUnwrap(controller.view)
        rootViewController.addChild(controller)
        rootViewController.view.addSubview(view)
        let safeOrigin = window.safeAreaLayoutGuide.layoutFrame.origin
        view.frame = .init(origin: safeOrigin, size: size)
        XCTAssertEqual(size, view.intrinsicContentSize)
        defer {
            view.removeFromSuperview()
            controller.removeFromParent()
        }
        return block(view)
    }
    
    func inWindowView<V: View, T>(_ swiftUIView: V, block: (UIView) -> T) throws -> T {
        let window = UIWindow()
        window.makeKeyAndVisible()
        let rootController = UIViewController()
        window.rootViewController = rootController
        let controller = UIHostingController(rootView: swiftUIView)
        let view = try XCTUnwrap(controller.view)
        let size = view.intrinsicContentSize
        let safeOrigin = rootController.view.safeAreaLayoutGuide.layoutFrame.origin
        view.frame = .init(origin: safeOrigin, size: size)
        rootController.addChild(controller)
        rootController.view.addSubview(controller.view)
        view.frame = .init(origin: safeOrigin, size: size)
        XCTAssertEqual(size, view.intrinsicContentSize)
        defer {
            view.removeFromSuperview()
            controller.removeFromParent()
        }
        return block(view)
    }

}

public func XCTAssertEqual(_ expression1: @autoclosure () throws -> CGSize, _ expression2: @autoclosure () throws -> CGSize, _ message: @autoclosure () -> String = "", file: StaticString = #filePath, line: UInt = #line) {
    let left = try! expression1()
    let right = try! expression2()
    let message = message()
    XCTAssertEqual(left.height, right.height, accuracy: 0.1, "height " + message, file: file, line: line)
    XCTAssertEqual(left.width, right.width, accuracy: 0.1, "width " + message, file: file, line: line)
}
