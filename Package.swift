// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SideNotch",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "SideNotch",
            targets: ["SideNotch"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "SideNotch",
            path: "SideNotch",
            exclude: [
                "Resources/Info.plist"
            ],
            resources: [
                .process("Resources/Assets.xcassets")
            ]
        )
    ]
)
