// swift-tools-version:5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-chat",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "SwiftChat", targets: ["SwiftChat"]),
    ],
    dependencies: [
        .package(url: "https://github.com/huggingface/swift-transformers", exact: "0.1.0"),
        .package(url: "https://github.com/buh/CompactSlider", exact: "1.1.5"),
        .package(url: "https://github.com/mxcl/Path.swift", exact: "1.4.0"),
    ],
    targets: [
        .executableTarget(
            name: "SwiftChat",
            dependencies: [
                .product(name: "Transformers", package: "swift-transformers"),
                .product(name: "CompactSlider", package: "CompactSlider"),
                .product(name: "Path", package: "Path.swift"),
            ]
        ),
        .testTarget(
            name: "SwiftChatTests",
            dependencies: []
        ),
        .testTarget(
            name: "SwiftChatUITests",
            dependencies: []
        ),
    ]
)
