/**
 *  https://github.com/tadija/AENetwork
 *  Copyright (c) Marko Tadić 2017
 *  Licensed under the MIT license. See LICENSE file.
 */

import Foundation

public protocol NetworkDelegate: class {
    func isValidCache(_ cache: CachedURLResponse, sender: Network) -> Bool
    func shouldSendRequest(_ request: URLRequest, sender: Network) -> Bool
    func didSendRequest(_ request: URLRequest, sender: Network)
    func shouldCacheResponse(from request: URLRequest, sender: Network) -> Bool
    func didCompleteRequest(_ request: URLRequest, sender: Network)
}

public extension NetworkDelegate {
    public func isValidCache(_ cache: CachedURLResponse, sender: Network) -> Bool {
        return true
    }
    public func shouldSendRequest(_ request: URLRequest, sender: Network) -> Bool {
        return true
    }
    public func didSendRequest(_ request: URLRequest, sender: Network) {}
    public func shouldCacheResponse(from request: URLRequest, sender: Network) -> Bool {
        return false
    }
    public func didCompleteRequest(_ request: URLRequest, sender: Network) {}
}

open class Network {

    // MARK: Types

    public enum Error: Swift.Error {
        case requestDenied(URLRequest)
    }
    
    // MARK: Singleton
    
    public static let shared = Network(fetcher: .shared, downloader: .shared)

    // MARK: Properties

    public weak var delegate: NetworkDelegate?

    public let fetcher: Fetcher
    public let downloader: Downloader
    public let cache: URLCache

    // MARK: Init
    
    public init(fetcher: Fetcher = .shared,
                downloader: Downloader = .shared,
                cache: URLCache = .shared) {
        self.fetcher = fetcher
        self.downloader = downloader
        self.cache = cache
    }

    // MARK: API

    public func sendRequest(_ request: URLRequest, completion: @escaping Fetcher.Completion.ThrowableResult) {
        if delegate?.shouldSendRequest(request, sender: self) ?? true {
            fetcher.sendRequest(request, completion: completion)
        } else {
            completion {
                throw Error.requestDenied(request)
            }
        }
    }

}

extension Network: FetcherDelegate {

    public func loadCachedResponse(for request: URLRequest) -> CachedURLResponse? {
        guard
            let cachedResponse = cache.cachedResponse(for: request),
            let delegate = delegate, delegate.isValidCache(cachedResponse, sender: self)
        else {
            cache.removeCachedResponse(for: request)
            return nil
        }
        return cachedResponse
    }

    public func didSendRequest(_ request: URLRequest) {
        delegate?.didSendRequest(request, sender: self)
    }

    public func cacheResponse(_ response: HTTPURLResponse, with data: Data, from request: URLRequest) {
        guard let delegate = delegate, delegate.shouldCacheResponse(from: request, sender: self) else {
            return
        }
        let cachedResponse = CachedURLResponse(response: response, data: data, storagePolicy: .allowed)
        cache.storeCachedResponse(cachedResponse, for: request)
    }

    public func didCompleteRequest(_ request: URLRequest) {
        delegate?.didCompleteRequest(request, sender: self)
    }

}
