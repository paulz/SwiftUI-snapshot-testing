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
            name: "VisualTestKit",
            targets: ["VisualTestKit"]),
        .library(
            name: "SnapshotTestingPreviewGroup",
            targets: ["PreviewGroup"]),
    ],
    dependencies: [
        .package(url: "https://github.com/paulz/HRCoder", .upToNextMajor(from: Version(2, 0, 0)))
    ],
    targets: [
        .target(
            name: "ViewSnapshotTesting",
            dependencies: [
                .target(name: "PreviewGroup"),
                .byName(name: "HRCoder")
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
        .binaryTarget(
            name: "VisualTestKit",
            url: "https://github.com/paulz/VisualTestKit.framework/releases/download/v0.0.2/VisualTestKit.xcframework.zip",
            checksum: "48b15eae813cde4136aa109fde05be1fe0dde6d28bc49b4e88f4fc294b926c2f"),
        .testTarget(
            name: "UnitTests",
            dependencies: [
                .target(name: "ViewSnapshotTesting"),
                .target(name: "VisualTestKit")
            ],
            path: "Tests",
            exclude: ["Snapshots"]
            ),
    ],
    swiftLanguageVersions: [.v5]
)
