// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Sanpo",
    defaultLocalization: "ja",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "App",
            targets: [
                "Constant",
                "MainTab",
            ]
        ),
        .library(
            name: "Widget",
            targets: [
                "WidgetFeature",
            ]
        ),
        .library(
            name: "Preview",
            targets: [
                "OnBoardingFeature",
                "HomeFeature",
                "HistoricalDataFeature",
                "SettingsFeature",
                "StyleGuide"
            ]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Constant",
            dependencies: []
        ),
        .target(
            name: "Extension",
            dependencies: [
                "Constant"
            ]
        ),
        .target(
            name: "HistoricalDataFeature",
            dependencies: [
                "Constant",
                "Extension",
                "Model",
                "StyleGuide"
            ]
        ),
        .target(
            name: "HomeFeature",
            dependencies: [
                "Constant",
                "Extension",
                "Model",
                "Service",
                "StyleGuide"
            ]
        ),
        .target(
            name: "MainTab",
            dependencies: [
                "HomeFeature",
                "HistoricalDataFeature"
            ]
        ),
        .target(
            name: "Model",
            dependencies: [
                "Constant",
                "Extension",
                "Service"
            ]
        ),
        .target(
            name: "OnBoardingFeature",
            dependencies: [
                "Extension",
            ]
        ),
        .target(
            name: "Service",
            dependencies: [
                "Constant",
                "Extension"
            ]
        ),
        .target(
            name: "SettingsFeature",
            dependencies: [
                "Extension",
                "StyleGuide"
            ]
        ),
        .target(
            name: "StyleGuide",
            dependencies: []
        ),
        .target(
            name: "WidgetFeature",
            dependencies: [
                "Constant",
                "Model"
            ]
        ),

        // Test
        .testTarget(
            name: "SanpoTests",
            dependencies: ["HomeFeature"]),
    ]
)
