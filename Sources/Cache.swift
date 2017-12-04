/**
 *  https://github.com/tadija/AENetwork
 *  Copyright (c) Marko Tadić 2017
 *  Licensed under the MIT license. See LICENSE file.
 */

import Foundation

public protocol NetworkCacheDelegate: class {
    func shouldCacheResponse(from request: URLRequest) -> Bool
    func isValidCache(_ cache: CachedURLResponse) -> Bool
}

open class Cache {

    // MARK: Singleton

    public static let shared = Cache()

    // MARK: Properties

    public let storage: URLCache
    public weak var delegate: NetworkCacheDelegate?

    // MARK: Init

    public init(storage: URLCache = .shared) {
        self.storage = storage
    }

    // MARK: API

    open func saveResponse(_ response: HTTPURLResponse, with data: Data, from request: URLRequest) {
        guard let delegate = delegate, delegate.shouldCacheResponse(from: request) else {
            return
        }
        let cache = CachedURLResponse(response: response, data: data, storagePolicy: .allowed)
        storage.storeCachedResponse(cache, for: request)
    }

    open func loadResponse(for request: URLRequest) -> CachedURLResponse? {
        guard
            let cache = storage.cachedResponse(for: request),
            let delegate = delegate,
            delegate.isValidCache(cache)
        else {
            storage.removeCachedResponse(for: request)
            return nil
        }
        return cache
    }

}
