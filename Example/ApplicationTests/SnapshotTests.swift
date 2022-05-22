import XCTest
@testable import Example
import SwiftUI_snapshot_test
import SwiftUI

class SnapshotTests: XCTestCase {
    func testViews() throws {
        verifySnapshot(FavoriteView_Previews.self)
        verifySnapshot(ContentView())
        verifySnapshot(Text("SwiftUI").foregroundColor(.red), "example")
    }
}
