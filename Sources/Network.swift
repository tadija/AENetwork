/**
 *  https://github.com/tadija/AENetwork
 *  Copyright (c) Marko Tadić 2017
 *  Licensed under the MIT license. See LICENSE file.
 */

import Foundation

open class Network {
    
    // MARK: Singleton
    
    public static let shared = Network(fetcher: .shared, downloader: .shared)

    // MARK: Properties

    public let fetcher: Fetcher
    public let downloader: Downloader

    public weak var cacheDelegate: NetworkCacheDelegate? {
        didSet {
            fetcher.cache.delegate = cacheDelegate
        }
    }

    public var isCacheEnabled: Bool = false
    public var shouldCacheRequestBlock: ((URLRequest) -> Bool)?
    public var validateCachedResponseBlock: ((CachedURLResponse) -> Bool)?

    // MARK: Init
    
    public init(fetcher: Fetcher = .shared,
                downloader: Downloader = .shared) {
        self.fetcher = fetcher
        self.downloader = downloader
        self.fetcher.cache.delegate = self
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
