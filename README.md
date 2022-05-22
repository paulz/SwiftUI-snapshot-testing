# SwiftUI-snapshot-testing
Practical SwiftUI Snapshot Testing

[![Build and Test](https://github.com/paulz/SwiftUI-snapshot-testing/actions/workflows/build-and-test.yml/badge.svg)](https://github.com/paulz/SwiftUI-snapshot-testing/actions/workflows/build-and-test.yml)

1. Compare Actual SwiftUI View with expected image with **color accuracy**
2. **Overwrite** Expected with Actual on failure
3. Attach Image **Difference** to test failure

This allows simple snapshot tests for SwiftUI views and previews.

## Installation

Add Swift Package to a project Test target

## Example

See [Example iOS app](https://github.com/paulz/SwiftUI-snapshot-testing/tree/main/Example) project with [SnapshotTests.swift](https://github.com/paulz/SwiftUI-snapshot-testing/blob/main/Example/ApplicationTests/SnapshotTests.swift)

    func testViews() {
        verifySnapshot(FavoriteView_Previews.self)
        verifySnapshot(ContentView())
        verifySnapshot(Text("SwiftUI").foregroundColor(.red), "example")
    }
