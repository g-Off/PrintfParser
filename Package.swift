// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "PrintfParser",
    products: [
        .library(
            name: "PrintfParser",
            targets: ["PrintfParser"]),
    ],
    targets: [
        .target(
            name: "PrintfParser",
            dependencies: []),
        .testTarget(
            name: "PrintfParserTests",
            dependencies: ["PrintfParser"]),
    ]
)
