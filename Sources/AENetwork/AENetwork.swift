/**
 *  https://github.com/tadija/AENetwork
 *  Copyright (c) Marko Tadić 2017
 *  Licensed under the MIT license. See LICENSE file.
 */

import Foundation

public protocol AENetworkCacheDelegate: class {
    func shouldCacheResponse(from request: URLRequest) -> Bool
    func isValidCache(_ cache: CachedURLResponse) -> Bool
}

open class AENetwork {
    
    // MARK: Types
    
    public struct Completion {
        public typealias ThrowData = (() throws -> Data) -> Void
        public typealias ThrowDictionary = (() throws -> [String : Any]) -> Void
        public typealias ThrowArray = (() throws -> [Any]) -> Void
    }
    
    public enum AENetworkError: Error {
        case badRequest
        case badResponse
        case parsingFailed
    }
    
    // MARK: Singleton
    
    public static let shared = AENetwork()
    
    // MARK: Init
    
    public init() {}
    
    // MARK: Properties
    
    public weak var cacheDelegate: AENetworkCacheDelegate?
    
    // MARK: API
    
    public func fetchData(with request: URLRequest, completion: @escaping Completion.ThrowData) {
        if let cachedResponse = cachedResponse(for: request) {
            completion {
                return cachedResponse.data
            }
        } else {
            sendRequest(request, completion: completion)
        }
    }
    
    public func fetchDictionary(with request: URLRequest, completion: @escaping Completion.ThrowDictionary) {
        fetchData(with: request) { [weak self] (closure) -> Void in
            do {
                let data = try closure()
                let dictionary = try self?.parseJSONDictionary(with: data) ?? [String : Any]()
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
    
    public func fetchArray(with request: URLRequest, completion: @escaping Completion.ThrowArray) {
        fetchData(with: request) { [weak self] (closure) -> Void in
            do {
                let data = try closure()
                let array = try self?.parseJSONArray(with: data) ?? [Any]()
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

// MARK: - Request / Response

extension AENetwork {
    
    fileprivate func sendRequest(_ request: URLRequest, completion: @escaping Completion.ThrowData) {
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
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
                                completion: Completion.ThrowData) {
        switch response.statusCode {
        case 200 ..< 300:
            if let delegate = cacheDelegate, delegate.shouldCacheResponse(from: request) {
                cacheResponse(response, with: data, from: request)
            }
            completion {
                return data
            }
        default:
            completion {
                throw AENetworkError.badResponse
            }
        }
    }
    
    private func handleResponseError(_ error: Error?,
                                     from request: URLRequest,
                                     completion: @escaping Completion.ThrowData) {
        if let error = error as NSError? {
            if error.domain == NSURLErrorDomain && error.code == NSURLErrorNetworkConnectionLost {
                // Retry request because of the iOS bug - SEE: https://github.com/AFNetworking/AFNetworking/issues/2314
                fetchData(with: request, completion: completion)
            } else {
                completion {
                    throw error
                }
            }
        } else {
            completion {
                throw AENetworkError.badResponse
            }
        }
    }
    
}

// MARK: - Parse

extension AENetwork {
    
    fileprivate func parseJSONDictionary(with data: Data) throws -> [String : Any] {
        return try parseJSON(data: data)
    }
    
    fileprivate func parseJSONArray(with data: Data) throws -> [Any] {
        return try parseJSON(data: data)
    }
    
    private func parseJSON<T>(data: Data) throws -> T {
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            if let json = json as? T {
                return json
            } else {
                throw AENetworkError.parsingFailed
            }
        } catch {
            throw error
        }
    }
    
}

// MARK: - Cache

extension AENetwork {
    
    fileprivate func cacheResponse(_ response: HTTPURLResponse, with data: Data, from request: URLRequest) {
        let cache = CachedURLResponse(response: response, data: data, storagePolicy: .allowed)
        URLCache.shared.storeCachedResponse(cache, for: request)
    }
    
    fileprivate func cachedResponse(for request: URLRequest) -> CachedURLResponse? {
        guard
            let cache = URLCache.shared.cachedResponse(for: request),
            let delegate = cacheDelegate
        else {
            return nil
        }

        if delegate.isValidCache(cache) {
            return cache
        } else {
            URLCache.shared.removeCachedResponse(for: request)
            return nil
        }
    }
    
}

// MARK: - URL Parameters

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
