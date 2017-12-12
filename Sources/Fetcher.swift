/**
 *  https://github.com/tadija/AENetwork
 *  Copyright (c) Marko Tadić 2017
 *  Licensed under the MIT license. See LICENSE file.
 */

import Foundation

open class Fetcher {

    // MARK: Types

    public struct Completion {
        public typealias ThrowableData = (() throws -> Data) -> Void
        public typealias ThrowableDictionary = (() throws -> [String : Any]) -> Void
        public typealias ThrowableArray = (() throws -> [Any]) -> Void
    }

    public enum RouterError: Error {
        case badRequest
        case badResponse
    }

    // MARK: Singleton

    public static let shared = Fetcher()

    // MARK: Properties

    public let session: URLSession
    public let parser: Parser
    public let cache: Cache

    // MARK: Init

    public init(session: URLSession = .shared,
                parser: Parser = .shared,
                cache: Cache = .shared) {
        self.session = session
        self.parser = parser
        self.cache = cache
    }

}

public extension Fetcher {

    // MARK: API

    public func data(with request: URLRequest, completion: @escaping Completion.ThrowableData) {
        if let cachedResponse = cache.loadResponse(for: request) {
            completion {
                return cachedResponse.data
            }
        } else {
            sendRequest(request, completion: completion)
        }
    }

    public func dictionary(with request: URLRequest, completion: @escaping Completion.ThrowableDictionary) {
        data(with: request) { [weak self] (closure) -> Void in
            do {
                let data = try closure()
                let dictionary = try self?.parser.jsonDictionary(from: data) ?? [String : Any]()
                completion {
                    return dictionary
                }
            } catch {
                completion {
                    throw error
                }
            }
        }
    }

    public func array(with request: URLRequest, completion: @escaping Completion.ThrowableArray) {
        data(with: request) { [weak self] (closure) -> Void in
            do {
                let data = try closure()
                let array = try self?.parser.jsonArray(from: data) ?? [Any]()
                completion {
                    return array
                }
            } catch {
                completion {
                    throw error
                }
            }
        }
    }

}

extension Fetcher {

    // MARK: Request / Response

    fileprivate func sendRequest(_ request: URLRequest, completion: @escaping Completion.ThrowableData) {
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
                                completion: Completion.ThrowableData) {
        switch response.statusCode {
        case 200 ..< 300:
            cache.saveResponse(response, with: data, from: request)
            completion {
                return data
            }
        default:
            completion {
                throw RouterError.badResponse
            }
        }
    }

    private func handleResponseError(_ error: Error?,
                                     from request: URLRequest,
                                     completion: @escaping Completion.ThrowableData) {
        if let error = error as NSError? {
            if error.domain == NSURLErrorDomain && error.code == NSURLErrorNetworkConnectionLost {
                // Retry request because of the iOS bug - SEE: https://github.com/AFNetworking/AFNetworking/issues/2314
                data(with: request, completion: completion)
            } else {
                completion {
                    throw error
                }
            }
        } else {
            completion {
                throw RouterError.badResponse
            }
        }
    }

}
