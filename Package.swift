// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Sanpo",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "App",
            targets: ["Sanpo"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Sanpo",
            dependencies: []),
        .testTarget(
            name: "SanpoTests",
            dependencies: ["Sanpo"]),
    ]
)
