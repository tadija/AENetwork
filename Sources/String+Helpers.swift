/**
 *  https://github.com/tadija/AENetwork
 *  Copyright (c) Marko Tadić 2017-2018
 *  Licensed under the MIT license. See LICENSE file.
 */

import Foundation

public extension String {
    public static let unavailable = "n/a"

    public var url: URL {
        return URL(string: self) ?? URL.invalid
    }
}
