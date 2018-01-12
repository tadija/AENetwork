/**
 *  https://github.com/tadija/AENetwork
 *  Copyright (c) Marko Tadić 2017
 *  Licensed under the MIT license. See LICENSE file.
 */

import Foundation

open class Fetcher {

    // MARK: Types

    public typealias ThrowableResult = (() throws -> Result) -> Void

    public struct Result {
        public let response: HTTPURLResponse
        public let data: Data

        public var dictionary: [String : Any]? {
            return try? toDictionary()
        }

        public var array: [Any]? {
            return try? toArray()
        }

        public func toDictionary() throws -> [String : Any] {
            return try data.toDictionary()
        }

        public func toArray() throws -> [Any] {
            return try data.toArray()
        }
    }

    public enum Error: Swift.Error {
        case badResponse(HTTPURLResponse?, Data?)
    }

    // MARK: Singleton

    public static let shared = Fetcher()

    // MARK: Properties

    public let session: URLSession

    // MARK: Init

    public init(session: URLSession = .shared) {
        self.session = session
    }

    // MARK: API

    public func sendRequest(_ request: URLRequest, completion: @escaping ThrowableResult) {
        session.dataTask(with: request) { [weak self] data, response, error in
            if let response = response as? HTTPURLResponse, let data = data, error == nil {
                self?.handleValidResponse(response, with: data, from: request, completion: completion)
            } else {
                self?.handleResponseError(error, from: request, completion: completion)
            }
        }.resume()
    }

    // MARK: Helpers

    private func handleValidResponse(_ response: HTTPURLResponse,
                                with data: Data,
                                from request: URLRequest,
                                completion: ThrowableResult) {
        switch response.statusCode {
        case 200 ..< 300:
            completion {
                return Result(response: response, data: data)
            }
        default:
            completion {
                throw Error.badResponse(response, data)
            }
        }
    }

    private func handleResponseError(_ error: Swift.Error?,
                                     from request: URLRequest,
                                     completion: @escaping ThrowableResult) {
        if let error = error as NSError? {
            if error.domain == NSURLErrorDomain && error.code == NSURLErrorNetworkConnectionLost {
                // Retry request because of the iOS bug - SEE: https://github.com/AFNetworking/AFNetworking/issues/2314
                sendRequest(request, completion: completion)
            } else {
                completion {
                    throw error
                }
            }
        } else {
            completion {
                throw Error.badResponse(nil, nil)
            }
        }
    }

}
