/**
 *  https://github.com/tadija/AENetwork
 *  Copyright (c) Marko Tadić 2017
 *  Licensed under the MIT license. See LICENSE file.
 */

import Foundation

public protocol NetworkDelegate: class {
    func didSendRequest(_ request: URLRequest, sender: Network)
    func didFinishRequest(_ request: URLRequest, with result: Fetcher.Result, sender: Network)

    func tmp1(_ r: () throws -> Fetcher.Result, c: Fetcher.Completion.ThrowableResult)

    func isValidCache(_ cache: CachedURLResponse, sender: Network) -> Bool
    func shouldCacheResponse(from request: URLRequest, sender: Network) -> Bool
}

public extension NetworkDelegate {
    public func didSendRequest(_ request: URLRequest, sender: Network) {}
    public func didFinishRequest(_ request: URLRequest, with result: Fetcher.Result, sender: Network) {}

    func tmp1(_ r: () throws -> Fetcher.Result, c: Fetcher.Completion.ThrowableResult) {
        do {
            let res = try r()
            c {
                return res
            }
        } catch {
            c {
                throw error
            }
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
        if let cachedResponse = loadCachedResponse(for: request) {
            completion {
                let httpResponse = cachedResponse.response as! HTTPURLResponse
                return Fetcher.Result(response: httpResponse, data: cachedResponse.data)
            }
        } else {
            performNetworkRequest(request, completion: completion)
        }
    }

    // MARK: Helpers

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
//            do {
//                let result = try result()
//                self?.handleNetworkResponse(from: request, with: result)
//                completion {
//                    return result
//                }
//            } catch {
//                completion {
//                    throw error
//                }
//            }

            self?.delegate?.tmp1(result, c: completion)

        })
        delegate?.didSendRequest(request, sender: self)
    }

    private func handleNetworkResponse(from request: URLRequest, with result: Fetcher.Result) {
        tryCachingResponse(result.response, with: result.data, from: request)
        delegate?.didFinishRequest(request, with: result, sender: self)
    }

    private func tryCachingResponse(_ response: HTTPURLResponse, with data: Data, from request: URLRequest) {
        guard let delegate = delegate, delegate.shouldCacheResponse(from: request, sender: self) else {
            return
        }
        let cachedResponse = CachedURLResponse(response: response, data: data, storagePolicy: .allowed)
        cache.storeCachedResponse(cachedResponse, for: request)
    }

}
