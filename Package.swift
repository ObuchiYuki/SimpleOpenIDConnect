// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SimpleOpenIDConnect",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .watchOS(.v6),
        .tvOS(.v13)
    ],
    products: [
        .library(name: "SimpleOpenIDConnect", targets: ["SimpleOpenIDConnect"]),
    ],
    targets: [
        .target(name: "SimpleOpenIDConnect"),
        .testTarget(
            name: "SimpleOpenIDConnectTests",
            dependencies: ["SimpleOpenIDConnect"]
        ),
    ]
)
