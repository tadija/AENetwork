/**
 *  https://github.com/tadija/AENetwork
 *  Copyright (c) Marko Tadić 2017
 *  Licensed under the MIT license. See LICENSE file.
 */

import Foundation

public protocol NetworkDelegate: class {
    func willSendRequest(_ request: URLRequest, sender: Network)
    func willReceiveResult(_ result: () throws -> Network.FetchResult,
                          from request: URLRequest, sender: Network)
}

public extension NetworkDelegate {
    public func willSendRequest(_ request: URLRequest, sender: Network) {}
    public func willReceiveResult(_ result: () throws -> Network.FetchResult,
                                 from request: URLRequest, sender: Network) {}
}

open class Network {

    // MARK: Types

    public typealias FetchResult = Fetcher.Result
    public typealias FetchError = Fetcher.Error

    public struct Completion {
        public typealias ThrowableFetchResult = (() throws -> FetchResult) -> Void
    }
    
    // MARK: Singleton
    
    public static let shared = Network()

    // MARK: Properties

    public weak var delegate: NetworkDelegate?

    public let reachability: Reachability
    public let fetcher: Fetcher
    public let downloader: Downloader

    // MARK: Init
    
    public init(reachability: Reachability = .shared,
                fetcher: Fetcher = .shared,
                downloader: Downloader = .shared)
    {
        self.reachability = reachability
        self.fetcher = fetcher
        self.downloader = downloader
    }

    // MARK: API

    public func sendRequest(_ request: URLRequest,
                            completionQueue: DispatchQueue = .main,
                            completion: @escaping Completion.ThrowableFetchResult) {
        delegate?.willSendRequest(request, sender: self)
        fetcher.sendRequest(request) { [unowned self] (result) in
            self.delegate?.willReceiveResult(result, from: request, sender: self)
            self.returnResult(result, in: completionQueue, completion: completion)
        }
    }

    private func returnResult(_ result: () throws -> FetchResult,
                              in queue: DispatchQueue,
                              completion: @escaping Completion.ThrowableFetchResult) {
        do {
            let result = try result()
            queue.async {
                completion {
                    return result
                }
            }
        } catch {
            queue.async {
                completion {
                    throw error
                }
            }
        }
    }

}
