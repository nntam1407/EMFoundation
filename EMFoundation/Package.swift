// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "EMFoundation",
    platforms: [
        .iOS(.v13),
        .macCatalyst(.v13),
        .macOS(.v10_15),
        .watchOS(.v7)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "EMFoundation",
            type: .static,
            targets: ["EMFoundation"]
        ),
        .library(
            name: "EMUIKit",
            type: .static,
            targets: ["EMUIKit"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/SnapKit/SnapKit.git", .upToNextMajor(from: "5.0.1"))
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "EMFoundation",
            path: "EMFoundation/Sources"
        ),
        .target(
            name: "EMUIKit",
            dependencies: [
                "EMFoundation",
                .product(name: "SnapKit", package: "SnapKit")
            ],
            path: "EMUIKit/Sources"
        )
    ]
)
