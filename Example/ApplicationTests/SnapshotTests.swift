import XCTest
@testable import Example
import SwiftUI_snapshot_test

class SnapshotTests: XCTestCase {
    func testContentView() throws {
        try verifySnapshot(ContentView(), "content-view.png")
        try verifySnapshot(FavoriteView())
    }
}
