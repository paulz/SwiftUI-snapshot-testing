// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftUI-snapshot-testing",
    platforms: [.macOS(.v12),
                .iOS(.v14)],
    products: [
        .library(
            name: "SwiftUI-snapshot-testing",
            targets: ["SwiftUI-snapshot-testing"]),
    ],
    targets: [
        .target(
            name: "SwiftUI-snapshot-testing",
            dependencies: [],
            path: "Sources"
        ),
        .testTarget(
            name: "UnitTests",
            dependencies: ["SwiftUI-snapshot-testing"],
            path: "Tests",
            exclude: ["Snapshots"]
            ),
    ],
    swiftLanguageVersions: [.v5]
)
