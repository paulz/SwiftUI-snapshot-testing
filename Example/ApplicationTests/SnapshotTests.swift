import XCTest
@testable import Example
import SwiftUI_snapshot_test
import SwiftUI


class SnapshotTests: XCTestCase {
    func testViews() throws {
        SnapshotsConfiguration.withColorAccuracy(0) {
            verifySnapshot(FavoriteView_Previews.self)
            verifySnapshot(SimpleView())
            verifySnapshot(Text("SwiftUI").foregroundColor(.red), "example")
        }
    }
    func testDefaultNameShouldNotIncludeModifiers() {
        verifySnapshot(ContentView_Previews.previews)
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
