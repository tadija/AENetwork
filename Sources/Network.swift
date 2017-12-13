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

open class Network {
    
    // MARK: Singleton
    
    public static let shared = Network(fetcher: .shared, downloader: .shared)

    // MARK: Properties

    public weak var delegate: NetworkDelegate?

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
        delegate?.didSendRequest(request, sender: self)
    }

    public func fetchData(with request: URLRequest, completion: @escaping Completion.FailableData) {
        fetcher.data(with: request) { (closure) in
            do {
                let result = try closure()
                completion(result, nil)
            } catch {
                completion(nil, error)
            }
        }
        delegate?.didSendRequest(request, sender: self)
    }

    public func fetchDictionary(with request: URLRequest, completion: @escaping Completion.ThrowableDictionary) {
        fetcher.dictionary(with: request, completion: completion)
        delegate?.didSendRequest(request, sender: self)
    }

    public func fetchDictionary(with request: URLRequest, completion: @escaping Completion.FailableDictionary) {
        fetcher.dictionary(with: request) { (closure) in
            do {
                let result = try closure()
                completion(result, nil)
            } catch {
                completion(nil, error)
            }
        }
        delegate?.didSendRequest(request, sender: self)
    }

    public func fetchArray(with request: URLRequest, completion: @escaping Completion.ThrowableArray) {
        fetcher.array(with: request, completion: completion)
        delegate?.didSendRequest(request, sender: self)
    }

    public func fetchArray(with request: URLRequest, completion: @escaping Completion.FailableArray) {
        fetcher.array(with: request) { (closure) in
            do {
                let result = try closure()
                completion(result, nil)
            } catch {
                completion(nil, error)
            }
        }
        delegate?.didSendRequest(request, sender: self)
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
