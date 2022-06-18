import Foundation

public struct SnapshotsConfiguration {
    public var folderName = "Snapshots"
    public var folderUrl: URL? = nil
    public var overwriteOnFailure = true
    public var colorAccuracy: Float = 0.02
    
    public static func withColorAccuracy(_ value: Float, block: ()->Void) {
        let previous = snapshotsConfiguration
        snapshotsConfiguration.colorAccuracy = value
        block()
        snapshotsConfiguration = previous
    }
    public static func resource(bundle: Bundle) {
        snapshotsConfiguration.folderUrl = bundle
            .resourceURL!
            .appendingPathComponent(snapshotsConfiguration.folderName)
        snapshotsConfiguration.overwriteOnFailure = false
    }
    public static func useSnapshots<T>(bundledWith aClass: T.Type = T.self) where T: AnyObject {
        resource(bundle: Bundle(for: aClass))
    }
    public static func useSnapshots<T>(bundledWith aClass: T) where T: AnyObject {
        useSnapshots(bundledWith: T.self)
    }
}

public var snapshotsConfiguration = SnapshotsConfiguration()
