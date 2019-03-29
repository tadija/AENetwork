/**
 *  https://github.com/tadija/AENetwork
 *  Copyright (c) Marko Tadić 2017-2019
 *  Licensed under the MIT license. See LICENSE file.
 */

import Foundation

public extension String {
    static let unavailable = "n/a"

    var url: URL {
        return URL(string: self) ?? URL.invalid
    }
}
