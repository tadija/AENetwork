// swift-tools-version:4.0

/**
 *  https://github.com/tadija/AENetwork
 *  Copyright (c) Marko Tadić 2017
 *  Licensed under the MIT license. See LICENSE file.
 */

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
