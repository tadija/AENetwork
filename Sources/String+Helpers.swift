/**
 *  https://github.com/tadija/AENetwork
 *  Copyright (c) Marko Tadić 2017
 *  Licensed under the MIT license. See LICENSE file.
 */

import Foundation

extension String {

    // MARK: Constants

    static let unavailable = "n/a"

    // MARK: Properties

    public var url: URL {
        return URL(string: self) ?? URL.invalid
    }

}
