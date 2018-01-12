/**
 *  https://github.com/tadija/AENetwork
 *  Copyright (c) Marko Tadić 2017
 *  Licensed under the MIT license. See LICENSE file.
 */

import Foundation

public protocol NetworkDelegate: class {
    func interceptRequest(_ request: URLRequest, sender: Network) throws -> URLRequest
    func didSendRequest(_ request: URLRequest, sender: Network)
    func interceptResult(_ result: () throws -> Network.FetchResult, from request: URLRequest,
                         completion: @escaping Network.Completion.ThrowableFetchResult, sender: Network)
    func willProvideResultFromCache(for request: URLRequest, sender: Network)
    func didReceiveResult(_ result: () throws -> Network.FetchResult,
                          from request: URLRequest, sender: Network)

    func isValidCache(_ cache: CachedURLResponse, sender: Network) -> Bool
    func shouldCacheResponse(from request: URLRequest, sender: Network) -> Bool
}

public extension NetworkDelegate {
    public func interceptRequest(_ request: URLRequest, sender: Network) throws -> URLRequest {
        return request
    }
    public func didSendRequest(_ request: URLRequest, sender: Network) {}
    public func interceptResult(_ result: () throws -> Network.FetchResult, from request: URLRequest,
                                completion: @escaping Network.Completion.ThrowableFetchResult, sender: Network) {
        completion {
            return try result()
        }
    }
    public func willProvideResultFromCache(for request: URLRequest, sender: Network) {}
    public func didReceiveResult(_ result: () throws -> Network.FetchResult,
                                 from request: URLRequest, sender: Network) {}

    public func isValidCache(_ cache: CachedURLResponse, sender: Network) -> Bool {
        return false
    }
    public func shouldCacheResponse(from request: URLRequest, sender: Network) -> Bool {
        return false
    }
}

open class Network {

    // MARK: Types

    public typealias FetchResult = Fetcher.Result

    public struct Completion {
        public typealias ThrowableFetchResult = (() throws -> FetchResult) -> Void
    }
    
    // MARK: Singleton
    
    public static let shared = Network()

    // MARK: Properties

    public weak var delegate: NetworkDelegate?

    public let reachability: Reachability
    public let fetcher: Fetcher
    public let downloader: Downloader
    public let cache: URLCache

    // MARK: Init
    
    public init(reachability: Reachability = .shared,
                fetcher: Fetcher = .shared,
                downloader: Downloader = .shared,
                cache: URLCache = .shared)
    {
        self.reachability = reachability
        self.fetcher = fetcher
        self.downloader = downloader
        self.cache = cache
    }

    // MARK: API

    public func sendRequest(_ request: URLRequest,
                            completionQueue: DispatchQueue? = nil,
                            completion: @escaping Completion.ThrowableFetchResult) {
        dispatchRequest(request, completionQueue: completionQueue, completion: completion)
    }

    // MARK: Helpers

    private func dispatchRequest(_ request: URLRequest,
                                completionQueue: DispatchQueue? = nil,
                                completion: @escaping Completion.ThrowableFetchResult) {
        delegate?.didSendRequest(request, sender: self)
        performRequest(request) { [weak self] (result) in
            if let strongSelf = self {
                strongSelf.delegate?.didReceiveResult(result, from: request, sender: strongSelf)
            }
            
            if let queue = completionQueue {
                do {
                    let result = try result()
                    queue.async {
                        completion {
                            return result
                        }
                    }
                } catch {
                    queue.async {
                        completion {
                            throw error
                        }
                    }
                }
            } else {
                completion {
                    return try result()
                }
            }
        }
    }

    private func performRequest(_ request: URLRequest, completion: @escaping Completion.ThrowableFetchResult) {
        do {
            let modifiedRequest = try delegate?.interceptRequest(request, sender: self)
            let finalRequest = modifiedRequest ?? request
            provideResponse(for: finalRequest, completion: completion)
        } catch {
            completion {
                throw error
            }
        }
    }

    private func provideResponse(for request: URLRequest, completion: @escaping Completion.ThrowableFetchResult) {
        if let cachedResponse = loadCachedResponse(for: request) {
            delegate?.willProvideResultFromCache(for: request, sender: self)
            
            let httpResponse = cachedResponse.response as! HTTPURLResponse
            let result = FetchResult(response: httpResponse, data: cachedResponse.data)
            
            completion {
                return result
            }
        } else {
            performNetworkRequest(request, completion: completion)
        }
    }

    private func loadCachedResponse(for request: URLRequest) -> CachedURLResponse? {
        guard
            let cachedResponse = cache.cachedResponse(for: request),
            let delegate = delegate, delegate.isValidCache(cachedResponse, sender: self)
        else {
            cache.removeCachedResponse(for: request)
            return nil
        }
        return cachedResponse
    }

    private func performNetworkRequest(_ request: URLRequest, completion: @escaping Completion.ThrowableFetchResult) {
        fetcher.sendRequest(request, completion: { [weak self] (result) in
            if let weakSelf = self, let delegate = weakSelf.delegate {
                weakSelf.tryCachingResult(result, from: request, delegate: delegate)
                delegate.interceptResult(result, from: request, completion: completion, sender: weakSelf)
            } else {
                completion {
                    return try result()
                }
            }
        })
    }

    private func tryCachingResult(_ result: () throws -> FetchResult,
                                  from request: URLRequest,
                                  delegate: NetworkDelegate) {
        if delegate.shouldCacheResponse(from: request, sender: self), let result = try? result() {
            let response = CachedURLResponse(response: result.response, data: result.data, storagePolicy: .allowed)
            cache.storeCachedResponse(response, for: request)
        }
    }

}
