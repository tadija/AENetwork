/**
 *  https://github.com/tadija/AENetwork
 *  Copyright (c) Marko Tadić 2017
 *  Licensed under the MIT license. See LICENSE file.
 */

import Foundation

extension URL: ExpressibleByStringLiteral {

    public init(stringLiteral value: StaticString) {
        self = URL(string: "\(value)") ?? URL(string: "https://invalid.url")!
    }

}
