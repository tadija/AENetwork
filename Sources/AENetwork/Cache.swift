//
//  Cache.swift
//  AENetwork
//
//  Created by Marko Tadić on 12/1/17.
//

import Foundation

public protocol NetworkCacheDelegate: class {
    func shouldCacheResponse(from request: URLRequest) -> Bool
    func isValidCache(_ cache: CachedURLResponse) -> Bool
}

open class Cache {

    // MARK: Properties

    weak var delegate: NetworkCacheDelegate?

    // MARK: API

    open func saveResponse(_ response: HTTPURLResponse, with data: Data, from request: URLRequest) {
        let cache = CachedURLResponse(response: response, data: data, storagePolicy: .allowed)
        URLCache.shared.storeCachedResponse(cache, for: request)
    }

    open func loadResponse(for request: URLRequest) -> CachedURLResponse? {
        guard
            let cache = URLCache.shared.cachedResponse(for: request),
            let delegate = delegate
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
