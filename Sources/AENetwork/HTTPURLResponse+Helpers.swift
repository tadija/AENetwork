/**
 *  https://github.com/tadija/AENetwork
 *  Copyright (c) Marko Tadić 2017-2018
 *  Licensed under the MIT license. See LICENSE file.
 */

import Foundation

// MARK: - Headers

public extension HTTPURLResponse {
    public func headerValue(forKey key: String) -> Any? {
        let foundKey: String = allHeaderFields.keys.first {
            "\($0)".caseInsensitiveCompare(key) == .orderedSame
            } as? String ?? key
        return allHeaderFields[foundKey]
    }
}

// MARK: - Description

public extension HTTPURLResponse {
    public var shortDescription: String {
        let code = statusCode
        let status = HTTPURLResponse.localizedString(forStatusCode: code).capitalized
        return "\(code) \(status)"
    }
    public var fullDescription: String {
        let headers = "\(allHeaderFields as? [String : Any] ?? [String : String]())"
        return """
        - Response: \(shortDescription)
        - Headers: \(headers)
        """
    }
}
