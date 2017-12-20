/**
 *  https://github.com/tadija/AENetwork
 *  Copyright (c) Marko Tadić 2017
 *  Licensed under the MIT license. See LICENSE file.
 */

import Foundation

private let invalidURL = URL(string: "https://invalid.url")!

extension URL: ExpressibleByStringLiteral {
    public init(stringLiteral value: StaticString) {
        self = URL(string: "\(value)") ?? invalidURL
    }
}

extension String {
    public var url: URL {
        return URL(string: self) ?? invalidURL
    }
}
