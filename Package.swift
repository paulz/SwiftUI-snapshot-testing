// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftUI-snapshot-testing",
    platforms: [
        .iOS(.v14),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "SwiftUI_SnapshotTesting",
            targets: ["ViewSnapshotTesting"]),
        .library(
            name: "SnapshotTestingPreviewGroup",
            targets: ["PreviewGroup"]),
    ],
    targets: [
        .target(
            name: "ViewSnapshotTesting",
            dependencies: [.target(name: "PreviewGroup")],
            path: "Sources/ViewSnapshotTesting",
            linkerSettings: [
                .linkedFramework("XCTest", .when(platforms: [.iOS, .macOS]))
            ]
        ),
        .target(
            name: "PreviewGroup",
            dependencies: [],
            path: "Sources/PreviewGroup"
        ),
        .testTarget(
            name: "UnitTests",
            dependencies: [.target(name: "ViewSnapshotTesting")],
            path: "Tests",
            exclude: ["Snapshots"]
            ),
    ],
    swiftLanguageVersions: [.v5]
)
