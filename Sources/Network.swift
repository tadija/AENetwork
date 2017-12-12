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
}

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

    // MARK: API

    public func fetchData(with request: URLRequest, completion: @escaping Completion.ThrowableData) {
        fetcher.data(with: request, completion: completion)
    }

    public func fetchDictionary(with request: URLRequest, completion: @escaping Completion.ThrowableDictionary) {
        fetcher.dictionary(with: request, completion: completion)
    }

    public func fetchArray(with request: URLRequest, completion: @escaping Completion.ThrowableArray) {
        fetcher.array(with: request, completion: completion)
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
