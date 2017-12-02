/**
 *  https://github.com/tadija/AENetwork
 *  Copyright (c) Marko Tadić 2017
 *  Licensed under the MIT license. See LICENSE file.
 */

import Foundation

extension URL {

    /// Convenience method for adding parameters to URL.
    ///
    /// - Parameter parameters: Parameters to be added.
    /// - Returns: URL with added parameters.

    public func addingParameters(_ parameters: [String : String]) -> URL? {
        guard var components = URLComponents(url: self, resolvingAgainstBaseURL: false) else {
            return nil
        }
        components.queryItems = parameters.map { URLQueryItem(name: $0.0, value: $0.1) }
        return components.url
    }

    /// Convenience method for getting parameter value.
    ///
    /// - Parameter key: Parameter name.
    /// - Returns: Parameter value.

    public func parameterValue(forKey key: String) -> String? {
        guard
            let components = URLComponents(url: self, resolvingAgainstBaseURL: false),
            let queryItems = components.queryItems,
            let value = queryItems.filter({ $0.name == key }).first?.value
            else {
                return nil
        }
        return value
    }

}
