// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift_googlechat_bot",
    dependencies: [
        
        .package(url: "https://github.com/apple/swift-package-manager.git", from: "0.4.0"),
        .package(url: "https://github.com/swift-server/async-http-client.git", from: "1.0.0-alpha.1")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "swift_googlechat_bot",
            dependencies: ["SPMUtility","AsyncHTTPClient"]),
        .testTarget(
            name: "swift_googlechat_botTests",
            dependencies: ["swift_googlechat_bot"]),
        .testTarget(
            name: "AsyncHTTPTests",
            dependencies: ["AsyncHTTPClient"])
    ]
)
