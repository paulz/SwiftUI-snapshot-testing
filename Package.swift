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
    dependencies: [.package(url: "https://github.com/paulz/VisualTestKit.git", branch: "main")],
    targets: [
        .target(
            name: "ViewSnapshotTesting",
            dependencies: [
                .target(name: "PreviewGroup")
            ],
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
            dependencies: [
                .target(name: "ViewSnapshotTesting"),
                .product(name: "VisualTestKit", package: "VisualTestKit")
            ],
            path: "Tests",
            exclude: ["Snapshots"]
            ),
    ],
    swiftLanguageVersions: [.v5]
)
