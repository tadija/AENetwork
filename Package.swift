// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "AENetwork",
    products: [
        .library(name: "AENetwork", targets: ["AENetwork"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "AENetwork"),
        .testTarget(
            name: "AENetworkTests",
            dependencies: ["AENetwork"])
    ]
)
