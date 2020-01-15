/**
 *  https://github.com/tadija/AENetwork
 *  Copyright © 2017-2020 Marko Tadić
 *  Licensed under the MIT license
 */

import Foundation

public extension Data {

    enum SerializationError: Swift.Error {
        case jsonSerializationFailed
    }

    init(jsonWith any: Any) throws {
        self = try JSONSerialization.data(
            withJSONObject: any, options: .prettyPrinted
        )
    }

    func toDictionary() throws -> [String : Any] {
        return try serializeJSON()
    }

    func toArray() throws -> [Any] {
        return try serializeJSON()
    }

    // MARK: Helpers

    private func serializeJSON<T>() throws -> T {
        let jsonObject = try JSONSerialization.jsonObject(
            with: self, options: .allowFragments
        )
        guard let parsed = jsonObject as? T else {
            throw SerializationError.jsonSerializationFailed
        }
        return parsed
    }

}
