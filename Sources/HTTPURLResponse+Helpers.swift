/**
 *  https://github.com/tadija/AENetwork
 *  Copyright (c) Marko Tadić 2017
 *  Licensed under the MIT license. See LICENSE file.
 */

import Foundation

extension HTTPURLResponse {
    
    public func headerValue(forKey key: String) -> Any? {
        guard let index = allHeaderFields.index(where: {
            "\($0.key)".caseInsensitiveCompare(key) == .orderedSame
        }) else {
            return nil
        }
        return allHeaderFields[index].value
    }
    
}
