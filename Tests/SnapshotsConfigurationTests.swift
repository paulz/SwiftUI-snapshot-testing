import XCTest
import ViewSnapshotTesting

class SnapshotsConfigurationTests: XCTestCase {
    var previous: SnapshotsConfiguration!
    override func setUp() {
        previous = snapshotsConfiguration
    }
    override func tearDown() {
        snapshotsConfiguration = previous
    }
    func testWithAccuracyChangeAccuracyWithinBlock() throws {
        SnapshotsConfiguration.withColorAccuracy(0.001) {
            XCTAssertEqual(snapshotsConfiguration.colorAccuracy, 0.001)
        }
        XCTAssertEqual(snapshotsConfiguration.colorAccuracy, 0.02)
    }
    func testUseSnapshotsBundledWithShouldSetFolderUrl() {
        XCTAssertNil(snapshotsConfiguration.folderUrl)
        SnapshotsConfiguration.useSnapshots(bundledWith: self)
        XCTAssertEqual(snapshotsConfiguration.folderUrl, Bundle(for: type(of: self)).resourceURL!.appendingPathComponent("Snapshots"))
    }
}
