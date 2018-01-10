/**
 *  https://github.com/tadija/AENetwork
 *  Copyright (c) Marko Tadić 2017
 *  Licensed under the MIT license. See LICENSE file.
 */

import Foundation

public protocol NetworkDelegate: class {
    func interceptRequest(_ request: URLRequest, sender: Network) throws -> URLRequest
    func didSendRequest(_ request: URLRequest, sender: Network)
    func interceptResult(_ result: () throws -> Fetcher.Result, from request: URLRequest,
                         completion: @escaping Fetcher.Completion.ThrowableResult, sender: Network)

    func isValidCache(_ cache: CachedURLResponse, sender: Network) -> Bool
    func shouldCacheResponse(from request: URLRequest, sender: Network) -> Bool
}

public extension NetworkDelegate {
    public func interceptRequest(_ request: URLRequest, sender: Network) throws -> URLRequest {
        return request
    }
    public func didSendRequest(_ request: URLRequest, sender: Network) {}
    public func interceptResult(_ result: () throws -> Fetcher.Result, from request: URLRequest,
                                completion: @escaping Fetcher.Completion.ThrowableResult, sender: Network) {
        completion {
            return try result()
        }
    }

    public func isValidCache(_ cache: CachedURLResponse, sender: Network) -> Bool {
        return true
    }
    public func shouldCacheResponse(from request: URLRequest, sender: Network) -> Bool {
        return false
    }
}

open class Network {
    
    // MARK: Singleton
    
    public static let shared = Network(fetcher: .shared, downloader: .shared)

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
                            completion: @escaping Fetcher.Completion.ThrowableResult) {
        performRequest(request) { (result) in
            if let queue = completionQueue {
                queue.sync {
                    completion {
                        return try result()
                    }
                }
            } else {
                completion {
                    return try result()
                }
            }
        }
    }

    // MARK: Helpers

    private func performRequest(_ request: URLRequest, completion: @escaping Fetcher.Completion.ThrowableResult) {
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

    private func provideResponse(for request: URLRequest, completion: @escaping Fetcher.Completion.ThrowableResult) {
        if let cachedResponse = loadCachedResponse(for: request) {
            completion {
                let httpResponse = cachedResponse.response as! HTTPURLResponse
                return Fetcher.Result(response: httpResponse, data: cachedResponse.data)
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

    private func performNetworkRequest(_ request: URLRequest, completion: @escaping Fetcher.Completion.ThrowableResult) {
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
        delegate?.didSendRequest(request, sender: self)
    }

    private func tryCachingResult(_ result: () throws -> Fetcher.Result,
                                  from request: URLRequest,
                                  delegate: NetworkDelegate) {
        if delegate.shouldCacheResponse(from: request, sender: self), let result = try? result() {
            let response = CachedURLResponse(response: result.response, data: result.data, storagePolicy: .allowed)
            cache.storeCachedResponse(response, for: request)
        }
    }

}
