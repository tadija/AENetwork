/**
 *  https://github.com/tadija/AENetwork
 *  Copyright (c) Marko Tadić 2017
 *  Licensed under the MIT license. See LICENSE file.
 */

import Foundation

extension Data {

    // MARK: Types

    public enum SerializationError: Swift.Error {
        case parsingFailed
    }

    // MARK: API

    public init(jsonWith any: Any) throws {
        self = try JSONSerialization.data(withJSONObject: any, options: .prettyPrinted)
    }

    public func toDictionary() throws -> [String : Any] {
        return try serializeJSON()
    }

    public func toArray() throws -> [Any] {
        return try serializeJSON()
    }

    // MARK: Helpers

    private func serializeJSON<T>() throws -> T {
        let jsonObject = try JSONSerialization.jsonObject(with: self, options: .allowFragments)
        guard let parsed = jsonObject as? T else {
            throw SerializationError.parsingFailed
        }
        return parsed
    }

}
