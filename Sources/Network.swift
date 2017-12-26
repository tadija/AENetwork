/**
 *  https://github.com/tadija/AENetwork
 *  Copyright (c) Marko Tadić 2017
 *  Licensed under the MIT license. See LICENSE file.
 */

import Foundation

public protocol NetworkDelegate: class {
    func shouldSendRequest(_ request: URLRequest, sender: Network) -> Bool

    func willSendRequest(_ request: URLRequest, sender: Network)
    func didSendRequest(_ request: URLRequest, sender: Network)
    func didCompleteRequest(_ request: URLRequest, sender: Network)

    func isValidCache(_ cache: CachedURLResponse, sender: Network) -> Bool
    func shouldCacheResponse(from request: URLRequest, sender: Network) -> Bool
}

public extension NetworkDelegate {
    public func shouldSendRequest(_ request: URLRequest, sender: Network) -> Bool {
        return true
    }

    public func willSendRequest(_ request: URLRequest, sender: Network) {}
    public func didSendRequest(_ request: URLRequest, sender: Network) {}
    public func didCompleteRequest(_ request: URLRequest, sender: Network) {}

    public func isValidCache(_ cache: CachedURLResponse, sender: Network) -> Bool {
        return true
    }
    public func shouldCacheResponse(from request: URLRequest, sender: Network) -> Bool {
        return false
    }
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
    
    public init(fetcher: Fetcher = .shared, downloader: Downloader = .shared, cache: URLCache = .shared) {
        self.fetcher = fetcher
        self.downloader = downloader
        self.cache = cache
    }

    // MARK: API

    public func sendRequest(_ request: URLRequest, completion: @escaping Fetcher.Completion.ThrowableResult) {
        if delegate?.shouldSendRequest(request, sender: self) ?? true {
            if let cachedResponse = loadCachedResponse(for: request) {
                completion {
                    let httpResponse = cachedResponse.response as! HTTPURLResponse
                    return Fetcher.Result(response: httpResponse, data: cachedResponse.data)
                }
            } else {
                performNetworkRequest(request, completion: completion)
            }
        } else {
            completion {
                throw Error.requestDenied(request)
            }
        }
    }

    // MARK: Helpers

    private func performNetworkRequest(_ request: URLRequest, completion: @escaping Fetcher.Completion.ThrowableResult) {
        delegate?.willSendRequest(request, sender: self)
        fetcher.sendRequest(request, completion: { [weak self] (result) in
            defer {
                if let weakSelf = self {
                    weakSelf.delegate?.didCompleteRequest(request, sender: weakSelf)
                }
            }
            do {
                let result = try result()
                self?.cacheResponse(result.response, with: result.data, from: request)
                completion {
                    return result
                }
            } catch {
                completion {
                    throw error
                }
            }
        })
        delegate?.didSendRequest(request, sender: self)
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

    private func cacheResponse(_ response: HTTPURLResponse, with data: Data, from request: URLRequest) {
        guard let delegate = delegate, delegate.shouldCacheResponse(from: request, sender: self) else {
            return
        }
        let cachedResponse = CachedURLResponse(response: response, data: data, storagePolicy: .allowed)
        cache.storeCachedResponse(cachedResponse, for: request)
    }

}
