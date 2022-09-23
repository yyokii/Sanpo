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
            targets: [
                "MainTab"
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
            name: "HomeFeature",
            dependencies: [
                "Model"
            ]
        ),
        .target(
            name: "MainTab",
            dependencies: [
                "HomeFeature"
            ]
        ),
        .target(
            name: "Model",
            dependencies: [
                "Constant"
            ]
        ),
        .plugin(
            name: "SwiftLintPlugin",
            capability: .buildTool(),
            dependencies: [
                .target(name: "SwiftLintBinary"),
            ]
        ),
        .binaryTarget(
            name: "SwiftLintBinary",
            url: "https://github.com/realm/SwiftLint/releases/download/0.48.0/SwiftLintBinary-macos.artifactbundle.zip",
            checksum: "9c255e797260054296f9e4e4cd7e1339a15093d75f7c4227b9568d63edddba50"
        ),
        

        // Test
        .testTarget(
            name: "SanpoTests",
            dependencies: ["HomeFeature"]),
    ]
)

// Append common plugins
package.targets = package.targets.map { target -> Target in
    if target.type == .regular || target.type == .test {
        if target.plugins == nil {
            target.plugins = []
        }
        target.plugins?.append(.plugin(name: "SwiftLintPlugin"))
    }

    return target
}
