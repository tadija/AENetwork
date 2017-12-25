/**
 *  https://github.com/tadija/AENetwork
 *  Copyright (c) Marko Tadić 2017
 *  Licensed under the MIT license. See LICENSE file.
 */

import Foundation

public protocol FetcherDelegate: class {
    func cacheResponse(_ response: HTTPURLResponse, with data: Data, from request: URLRequest)
    func loadCachedResponse(for request: URLRequest) -> CachedURLResponse?
}

open class Fetcher {

    // MARK: Types

    public struct Result {
        let response: URLResponse
        let data: Data

        var httpResponse: HTTPURLResponse? {
            return response as? HTTPURLResponse
        }

        func dictionary() throws -> [String : Any] {
            return try data.toDictionary()
        }

        func array() throws -> [Any] {
            return try data.toArray()
        }
    }

    public struct Completion {
        public typealias ThrowableResult = (() throws -> Result) -> Void
    }

    public enum Error: Swift.Error {
        case badResponse(_: HTTPURLResponse?)
    }

    // MARK: Singleton

    public static let shared = Fetcher()

    // MARK: Properties

    public let session: URLSession
    public weak var delegate: FetcherDelegate?

    // MARK: Init

    public init(session: URLSession = .shared) {
        self.session = session
    }

    // MARK: API

    public func performRequest(_ request: URLRequest, completion: @escaping Completion.ThrowableResult) {
        if let cachedResponse = delegate?.loadCachedResponse(for: request) {
            completion {
                return Result(response: cachedResponse.response, data: cachedResponse.data)
            }
        } else {
            sendRequest(request, completion: completion)
        }
    }

}

extension Fetcher {

    // MARK: Request / Response

    fileprivate func sendRequest(_ request: URLRequest, completion: @escaping Completion.ThrowableResult) {
        session.dataTask(with: request) { [weak self] data, response, error in
            if let response = response as? HTTPURLResponse, let data = data, error == nil {
                self?.handleResponse(response, with: data, from: request, completion: completion)
            } else {
                self?.handleResponseError(error, from: request, completion: completion)
            }
        }.resume()
    }

    private func handleResponse(_ response: HTTPURLResponse,
                                with data: Data,
                                from request: URLRequest,
                                completion: Completion.ThrowableResult) {
        switch response.statusCode {
        case 200 ..< 300:
            delegate?.cacheResponse(response, with: data, from: request)
            completion {
                return Result(response: response, data: data)
            }
        default:
            completion {
                throw Error.badResponse(response)
            }
        }
    }

    private func handleResponseError(_ error: Swift.Error?,
                                     from request: URLRequest,
                                     completion: @escaping Completion.ThrowableResult) {
        if let error = error as NSError? {
            if error.domain == NSURLErrorDomain && error.code == NSURLErrorNetworkConnectionLost {
                // Retry request because of the iOS bug - SEE: https://github.com/AFNetworking/AFNetworking/issues/2314
                performRequest(request, completion: completion)
            } else {
                completion {
                    throw error
                }
            }
        } else {
            completion {
                throw Error.badResponse(nil)
            }
        }
    }

}
