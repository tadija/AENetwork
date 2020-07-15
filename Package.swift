// swift-tools-version:5.2

/**
 *  https://github.com/tadija/AENetwork
 *  Copyright © 2017-2020 Marko Tadić
 *  Licensed under the MIT license
 */

import PackageDescription

let package = Package(
    name: "AENetwork",
    products: [
        .library(
            name: "AENetwork",
            targets: ["AENetwork"]
        )
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
