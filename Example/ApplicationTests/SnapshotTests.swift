import XCTest
import Example
import SwiftUI_snapshot_test
import SwiftUI


class SnapshotTests: XCTestCase {
    func testViews() throws {
        verifySnapshot(FavoriteView_Previews.self, colorAccuracy: 0.05)
        verifySnapshot(SimpleView())
        verifySnapshot(Text("SwiftUI").foregroundColor(.red), "example", colorAccuracy: 0)
    }
    func testDefaultNameShouldNotIncludeModifiers() {
        verifySnapshot(ContentView_Previews.previews, colorAccuracy: 0)
    }
}

struct SimpleView: View {
    var body: some View {
        Text("Simple Text")
            .foregroundColor(.yellow)
            .background(Color.indigo)
            .padding()
    }
}
