import Foundation

public struct SnapshotsConfiguration {
    public var folderName = "Snapshots"
    public var folderUrl: URL? = nil
    public var overwriteOnFailure = true
    public var colorAccuracy: Float = 0.02
    public var useResources: Bool {
        get {
            !overwriteOnFailure
        }
        set {
            overwriteOnFailure = !newValue
        }
    }
    public static func withColorAccuracy(_ value: Float, block: ()->Void) {
        let previous = snapshotsConfiguration
        snapshotsConfiguration.colorAccuracy = value
        block()
        snapshotsConfiguration = previous
    }
}

public var snapshotsConfiguration = SnapshotsConfiguration()
