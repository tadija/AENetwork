/**
 *  https://github.com/tadija/AENetwork
 *  Copyright © 2017-2020 Marko Tadić
 *  Licensed under the MIT license
 */

import Foundation

// MARK: - ExpressibleByStringLiteral

extension URL: ExpressibleByStringLiteral {
    public static let mock = URL(string: "https://mock.url")!
    
    public init(stringLiteral value: StaticString) {
        self = "\(value)".url
    }
}

public extension String {
    var url: URL {
        return URL(string: self) ?? URL.mock
    }
}

// MARK: - Parameters

public extension URL {

    // MARK: Read

    var parameters: [String : String]? {
        guard
            let components = URLComponents(url: self, resolvingAgainstBaseURL: false),
            let queryItems = components.queryItems
        else { return nil }
        return queryItems.reduce(into: [String : String]()) {
            $0[$1.name] = $1.value
        }
    }

    func value(forParameterKey key: String) -> String? {
        return parameters?[key]
    }
    
    func stringValue(forParameterKey key: String) -> String {
        return value(forParameterKey: key) ?? String()
    }
    
    func boolValue(forParameterKey key: String) -> Bool? {
        return Bool(stringValue(forParameterKey: key))
    }
    
    func intValue(forParameterKey key: String) -> Int? {
        return Int(stringValue(forParameterKey: key))
    }
    
    func doubleValue(forParameterKey key: String) -> Double? {
        return Double(stringValue(forParameterKey: key))
    }

    // MARK: Write

    func addingParameters(_ parameters: [String : Any]) -> URL? {
        var components = URLComponents(url: self, resolvingAgainstBaseURL: false)
        components?.queryItems = parameters.map {
            URLQueryItem(name: $0.0, value: "\($0.1)")
        }
        return components?.url
    }

}
