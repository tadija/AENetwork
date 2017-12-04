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

    public let manager: URLCache
    public weak var delegate: NetworkCacheDelegate?

    // MARK: Init

    public init(manager: URLCache = .shared) {
        self.manager = manager
    }

    // MARK: API

    open func saveResponse(_ response: HTTPURLResponse, with data: Data, from request: URLRequest) {
        let cache = CachedURLResponse(response: response, data: data, storagePolicy: .allowed)
        manager.storeCachedResponse(cache, for: request)
    }

    open func loadResponse(for request: URLRequest) -> CachedURLResponse? {
        guard
            let cache = manager.cachedResponse(for: request),
            let delegate = delegate
        else {
            return nil
        }

        if delegate.isValidCache(cache) {
            return cache
        } else {
            manager.removeCachedResponse(for: request)
            return nil
        }
    }

}
