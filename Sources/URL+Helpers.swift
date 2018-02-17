/**
 *  https://github.com/tadija/AENetwork
 *  Copyright (c) Marko Tadić 2017-2018
 *  Licensed under the MIT license. See LICENSE file.
 */

import Foundation

extension URL: ExpressibleByStringLiteral {

    // MARK: Constants

    public static let invalid = URL(string: "https://invalid.url")!

    // MARK: Properties

    public var parameters: [String : String]? {
        guard
            let components = URLComponents(url: self, resolvingAgainstBaseURL: false),
            let queryItems = components.queryItems
        else { return nil }

        var params = [String : String]()
        queryItems.forEach { params[$0.name] = $0.value }
        return params
    }

    // MARK: ExpressibleByStringLiteral

    public init(stringLiteral value: StaticString) {
        self = URL(string: "\(value)") ?? URL.invalid
    }

    // MARK: API
    
    public mutating func addParameters(_ parameters: [String : Any]) {
        var components = URLComponents(url: self, resolvingAgainstBaseURL: false)
        components?.queryItems = parameters.map { URLQueryItem(name: $0.0, value: "\($0.1)") }
        self = components?.url ?? self
    }

    /// Convenience method for adding parameters to URL.
    ///
    /// - Parameter parameters: Parameters to be added.
    /// - Returns: URL with added parameters.
    public func addingParameters(_ parameters: [String : Any]) -> URL? {
        var copy = self
        copy.addParameters(parameters)
        return copy
    }

    /// Convenience method for getting parameter value.
    ///
    /// - Parameter key: Parameter name.
    /// - Returns: Parameter value.
    public func parameterValue(forKey key: String) -> String? {
        let value = parameters?[key]
        return value
    }
    
    public func stringValue(forParameterKey key: String) -> String {
        let value = parameterValue(forKey: key) ?? String()
        return value
    }
    
    public func boolValue(forParameterKey key: String) -> Bool? {
        let string = stringValue(forParameterKey: key)
        let value = Bool(string)
        return value
    }
    
    public func intValue(forParameterKey key: String) -> Int? {
        let string = stringValue(forParameterKey: key)
        let value = Int(string)
        return value
    }
    
    public func doubleValue(forParameterKey key: String) -> Double? {
        let string = stringValue(forParameterKey: key)
        let value = Double(string)
        return value
    }

}
