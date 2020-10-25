// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "Aphrodite",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .tvOS(.v13)
    ],
    products: [
        .library(
            name: "Aphrodite",
            targets: ["Aphrodite"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Aphrodite",
            dependencies: []
        ),
        .testTarget(
            name: "AphroditeTests",
            dependencies: ["Aphrodite"]
        ),
    ]
)
