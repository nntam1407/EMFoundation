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
        ),
        .library(
            name: "EMYouTubeScraper",
            type: .static,
            targets: ["EMYouTubeScraper"]
        ),
        .library(
            name: "EMScaffoldKit",
            type: .static,
            targets: ["EMScaffoldKit"]
        ),
        .library(
            name: "EMCaching",
            type: .static,
            targets: ["EMCaching"]
        ),
        .library(
            name: "EMNetworkKit",
            type: .static,
            targets: ["EMNetworkKit"]
        ),
        .library(
            name: "EMAppLanguage",
            type: .static,
            targets: ["EMAppLanguage"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/SnapKit/SnapKit.git", .upToNextMajor(from: "5.0.1")),
        .package(url: "https://github.com/scinfu/SwiftSoup.git", from: "2.6.0")
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
        ),
        .target(
            name: "EMYouTubeScraper",
            dependencies: [
                "EMFoundation",
                .product(name: "SwiftSoup", package: "SwiftSoup")
            ],
            path: "EMYouTubeScraper/Sources"
        ),
        .target(
            name: "EMScaffoldKit",
            dependencies: [
                "EMUIKit"
            ],
            path: "EMScaffoldKit/Sources"
        ),
        .target(
            name: "EMCaching",
            path: "EMCaching/Sources"
        ),
        .target(
            name: "EMNetworkKit",
            dependencies: [
                "EMFoundation"
            ],
            path: "EMNetworkKit/Sources"
        ),
        .target(
            name: "EMAppLanguage",
            path: "EMAppLanguage/Sources"
        )
    ]
)
