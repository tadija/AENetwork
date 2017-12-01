/**
 *  https://github.com/tadija/AENetwork
 *  Copyright (c) Marko Tadić 2017
 *  Licensed under the MIT license. See LICENSE file.
 */

import Foundation

class Parser {

    // MARK: Type

    enum ParserError: Error {
        case parsingFailed
    }

    // MARK: API

    func jsonDictionary(from data: Data) throws -> [String : Any] {
        return try parseJSON(data: data)
    }

    func jsonArray(from data: Data) throws -> [Any] {
        return try parseJSON(data: data)
    }

    // MARK: Helpers

    private func parseJSON<T>(data: Data) throws -> T {
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            if let json = json as? T {
                return json
            } else {
                throw ParserError.parsingFailed
            }
        } catch {
            throw error
        }
    }

}
