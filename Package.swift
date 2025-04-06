// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Sanpo",
    defaultLocalization: "en",
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
                "Components",
                "DataSummaryFeature",
                "OnBoardingFeature",
                "HomeFeature",
                "HistoricalDataFeature",
                "SettingsFeature",
                "StyleGuide",
                "WeatherFeature",
            ]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/MacPaw/OpenAI.git", from: "0.3.2"),
        .package(url: "https://github.com/firebase/firebase-ios-sdk", from: "11.10.0"),
    ],
    targets: [
        .target(
            name: "Constant",
            dependencies: []
        ),
        .target(
            name: "Components",
            dependencies: [
                "StyleGuide",
            ]
        ),
        .target(
            name: "DataSummaryFeature",
            dependencies: [
                "Components",
                "Model",
                "StyleGuide"
            ]
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
                "Components",
                "DataSummaryFeature",
                "Extension",
                "HistoricalDataFeature",
                "Model",
                "Service",
                "StyleGuide"
            ]
        ),
        .target(
            name: "MainTab",
            dependencies: [
                "HomeFeature",
                "WeatherFeature"
            ]
        ),
        .target(
            name: "Model",
            dependencies: [
                .product(name: "OpenAI", package: "OpenAI"),
                "Constant",
                "Extension",
                "Service",
                .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
                .product(name: "FirebaseFirestore", package: "firebase-ios-sdk"),
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
            name: "WeatherFeature",
            dependencies: [
                "Constant",
                "Model",
                "SafariView",
                "Service",
                "StyleGuide"
            ]
        ),
        .target(
            name: "WidgetFeature",
            dependencies: [
                "Constant",
                "Model"
            ]
        ),
        .target(
            name: "SafariView",
            dependencies: []
        ),

        // Test
        .testTarget(
            name: "SanpoTests",
            dependencies: ["HomeFeature"]),
    ]
)
