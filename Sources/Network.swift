/**
 *  https://github.com/tadija/AENetwork
 *  Copyright (c) Marko Tadić 2017
 *  Licensed under the MIT license. See LICENSE file.
 */

import Foundation

public struct Completion {
    public typealias ThrowableData = (() throws -> Data) -> Void
    public typealias ThrowableDictionary = (() throws -> [String : Any]) -> Void
    public typealias ThrowableArray = (() throws -> [Any]) -> Void

    public typealias FailableData = (Data?, Error?) -> Void
    public typealias FailableDictionary = ([String : Any]?, Error?) -> Void
    public typealias FailableArray = ([Any]?, Error?) -> Void
}

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

    public func fetchData(with request: URLRequest, completion: @escaping Completion.ThrowableData) {
        fetcher.data(with: request, completion: completion)
        delegate?.didSendRequest(request, sender: self)
    }

    public func fetchData(with request: URLRequest, completion: @escaping Completion.FailableData) {
        fetchData(with: request) { (closure) in
            do {
                let result = try closure()
                completion(result, nil)
            } catch {
                completion(nil, error)
            }
        }
    }

    public func fetchDictionary(with request: URLRequest, completion: @escaping Completion.ThrowableDictionary) {
        fetcher.dictionary(with: request, completion: completion)
        delegate?.didSendRequest(request, sender: self)
    }

    public func fetchDictionary(with request: URLRequest, completion: @escaping Completion.FailableDictionary) {
        fetchDictionary(with: request) { (closure) in
            do {
                let result = try closure()
                completion(result, nil)
            } catch {
                completion(nil, error)
            }
        }
    }

    public func fetchArray(with request: URLRequest, completion: @escaping Completion.ThrowableArray) {
        fetcher.array(with: request, completion: completion)
        delegate?.didSendRequest(request, sender: self)
    }

    public func fetchArray(with request: URLRequest, completion: @escaping Completion.FailableArray) {
        fetchArray(with: request) { (closure) in
            do {
                let result = try closure()
                completion(result, nil)
            } catch {
                completion(nil, error)
            }
        }
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
