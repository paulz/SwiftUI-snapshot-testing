import XCTest
@testable import Example
import SwiftUI_snapshot_test
import SwiftUI

class SnapshotTests: XCTestCase {
    func testContentView() throws {
        try verifySnapshot(ContentView(), "content-view")
        try verifySnapshot(FavoriteView_Previews.self)
    }
}
