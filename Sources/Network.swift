/**
 *  https://github.com/tadija/AENetwork
 *  Copyright (c) Marko Tadić 2017
 *  Licensed under the MIT license. See LICENSE file.
 */

import Foundation

public protocol NetworkDelegate: class {
    func didSendRequest(_ request: URLRequest, sender: Network)
}

public protocol NetworkCacheDelegate: class {
    func shouldCacheResponse(from request: URLRequest) -> Bool
    func isValidCache(_ cache: CachedURLResponse) -> Bool
}

open class Network {
    
    // MARK: Singleton
    
    public static let shared = Network(fetcher: .shared, downloader: .shared)

    // MARK: Properties

    public weak var delegate: NetworkDelegate?

    public let fetcher: Fetcher
    public let downloader: Downloader

    public let cache: URLCache
    public weak var cacheDelegate: NetworkCacheDelegate?

    // MARK: Init
    
    public init(fetcher: Fetcher = .shared,
                downloader: Downloader = .shared,
                cache: URLCache = .shared) {
        self.fetcher = fetcher
        self.downloader = downloader
        self.cache = cache
    }

    // MARK: API

    public func performRequest(_ request: URLRequest, completion: @escaping Fetcher.Completion.ThrowableResult) {
        fetcher.performRequest(request, completion: completion)
        delegate?.didSendRequest(request, sender: self)
    }

}

extension Network: FetcherDelegate {

    public func cacheResponse(_ response: HTTPURLResponse, with data: Data, from request: URLRequest) {
        guard
            let cacheDelegate = cacheDelegate,
            cacheDelegate.shouldCacheResponse(from: request)
        else {
            return
        }
        let cachedResponse = CachedURLResponse(response: response, data: data, storagePolicy: .allowed)
        cache.storeCachedResponse(cachedResponse, for: request)
    }

    public func loadCachedResponse(for request: URLRequest) -> CachedURLResponse? {
        guard
            let cachedResponse = cache.cachedResponse(for: request),
            let cacheDelegate = cacheDelegate,
            cacheDelegate.isValidCache(cachedResponse)
        else {
            cache.removeCachedResponse(for: request)
            return nil
        }
        return cachedResponse
    }

}
