/**
 *  https://github.com/tadija/AENetwork
 *  Copyright (c) Marko Tadić 2017
 *  Licensed under the MIT license. See LICENSE file.
 */

import Foundation

open class Network {
    
    // MARK: Singleton
    
    public static let shared = Network(router: .shared, downloader: .shared)

    // MARK: Properties

    public let router: Router
    public let downloader: Downloader

    public weak var cacheDelegate: NetworkCacheDelegate? {
        didSet {
            router.cache.delegate = cacheDelegate
        }
    }

    public var isCacheEnabled: Bool = false
    public var shouldCacheRequestBlock: ((URLRequest) -> Bool)?
    public var validateCachedResponseBlock: ((CachedURLResponse) -> Bool)?

    // MARK: Init
    
    public init(router: Router = .shared,
                downloader: Downloader = .shared) {
        self.router = router
        self.downloader = downloader
        self.router.cache.delegate = self
    }

}

extension Network: NetworkCacheDelegate {

    // MARK: NetworkCacheDelegate

    public func shouldCacheResponse(from request: URLRequest) -> Bool {
        return shouldCacheRequestBlock?(request) ?? isCacheEnabled
    }

    public func isValidCache(_ cache: CachedURLResponse) -> Bool {
        return validateCachedResponseBlock?(cache) ?? isCacheEnabled
    }

}
