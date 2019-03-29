// swift-tools-version:5.0

/**
 *  https://github.com/tadija/AENetwork
 *  Copyright (c) Marko Tadić 2017-2018
 *  Licensed under the MIT license. See LICENSE file.
 */

import PackageDescription

let package = Package(
    name: "AENetwork",
    products: [
        .library(
            name: "AENetwork",
            targets: ["AENetwork"])
    ],
    targets: [
        .target(
            name: "AENetwork"
        ),
        .testTarget(
            name: "AENetworkTests",
            dependencies: ["AENetwork"]
        )
    ]
)
