// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftUI-snapshot-testing",
    platforms: [.macOS(.v12),
                .iOS(.v14)],
    products: [
        .library(
            name: "SwiftUI_SnapshotTesting",
            targets: ["ViewSnapshotTesting"]),
    ],
    targets: [
        .target(
            name: "ViewSnapshotTesting",
            dependencies: [],
            path: "Sources",
            linkerSettings: [.linkedFramework("XCTest",
                                              .when(platforms: [.iOS,
                                                                .macOS,
                                                                .tvOS,
                                                                .watchOS]))]
        ),
        .testTarget(
            name: "UnitTests",
            dependencies: ["ViewSnapshotTesting"],
            path: "Tests",
            exclude: ["Snapshots"]
            ),
    ],
    swiftLanguageVersions: [.v5]
)
