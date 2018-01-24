/**
 *  https://github.com/tadija/AENetwork
 *  Copyright (c) Marko Tadić 2017-2018
 *  Licensed under the MIT license. See LICENSE file.
 */

import Foundation

extension HTTPURLResponse {

    // MARK: Properties

    public var shortDescription: String {
        let code = statusCode
        let status = HTTPURLResponse.localizedString(forStatusCode: code).capitalized
        return "\(code) \(status)"
    }

    // MARK: API
    
    public func headerValue(forKey key: String) -> Any? {
        guard let index = allHeaderFields.index(where: {
            "\($0.key)".caseInsensitiveCompare(key) == .orderedSame
        }) else {
            return nil
        }
        return allHeaderFields[index].value
    }
    
}
