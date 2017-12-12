/**
 *  https://github.com/tadija/AENetwork
 *  Copyright (c) Marko Tadić 2017
 *  Licensed under the MIT license. See LICENSE file.
 */

import Foundation

open class Parser {

    // MARK: Type

    public enum ParserError: Error {
        case parsingFailed
    }

    // MARK: Singleton

    public static let shared = Parser()

    // MARK: Init

    public init() {}

    // MARK: API

    open func dictionary(fromJSON data: Data) throws -> [String : Any] {
        return try parseJSON(data: data)
    }

    open func array(fromJSON data: Data) throws -> [Any] {
        return try parseJSON(data: data)
    }

    // MARK: Helpers

    private func parseJSON<T>(data: Data) throws -> T {
        let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
        if let json = json as? T {
            return json
        } else {
            throw ParserError.parsingFailed
        }
    }

}
