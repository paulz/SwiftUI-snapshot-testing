import XCTest
@testable import Example
import SwiftUI_snapshot_test
import SwiftUI

class SnapshotTests: XCTestCase {
    func testViews() throws {
        try verifySnapshot(FavoriteView_Previews.self)
        try verifySnapshot(ContentView())
        try verifySnapshot(Text("SwiftUI").foregroundColor(.red), "example")
    }
}
