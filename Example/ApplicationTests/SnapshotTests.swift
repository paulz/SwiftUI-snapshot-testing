import XCTest
@testable import Example
import SwiftUI_snapshot_test
import SwiftUI

class SnapshotTests: XCTestCase {
    func testViews() throws {
        verifySnapshot(FavoriteView_Previews.self, colorAccuracy: 0.05)
        verifySnapshot(ContentView(), colorAccuracy: 0)
        verifySnapshot(Text("SwiftUI").foregroundColor(.red), "example", colorAccuracy: 0)
    }
}
