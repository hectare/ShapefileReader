// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ShapefileReader",
    products: [
        .library(
            name: "ShapefileReader",
            targets: ["ShapefileReader"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "ShapefileReader",
            dependencies: []),
        .testTarget(
            name: "ShapefileReaderTests",
            dependencies: ["ShapefileReader"],
            resources: [.copy("Resources/lime")]),
    ]
)
