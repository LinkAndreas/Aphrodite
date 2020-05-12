//  Copyright © 2020 Andreas Link. All rights reserved.

// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "Aphrodite",
    platforms: [
        .macOS(.v10_15), .iOS(.v13), .tvOS(.v13)
    ],
    products: [
        .library(name: "Aphrodite", targets: ["Aphrodite"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Aphrodite"),
        .testTarget(
            name: "AphroditeTests",
            dependencies: ["Aphrodite"]
        )
    ]
)
