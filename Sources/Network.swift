/**
 *  https://github.com/tadija/AENetwork
 *  Copyright (c) Marko Tadić 2017
 *  Licensed under the MIT license. See LICENSE file.
 */

import Foundation

public protocol NetworkDelegate: class {
    func interceptRequest(_ request: URLRequest, sender: Network) throws -> URLRequest
    func didSendRequest(_ request: URLRequest, sender: Network)
    func interceptResult(_ result: () throws -> Network.FetchResult, from request: URLRequest,
                         completion: @escaping Network.Completion.ThrowableFetchResult, sender: Network)
    func didReceiveResult(_ result: () throws -> Network.FetchResult,
                          from request: URLRequest, sender: Network)
}

public extension NetworkDelegate {
    public func interceptRequest(_ request: URLRequest, sender: Network) throws -> URLRequest {
        return request
    }
    public func didSendRequest(_ request: URLRequest, sender: Network) {}
    public func interceptResult(_ result: () throws -> Network.FetchResult, from request: URLRequest,
                                completion: @escaping Network.Completion.ThrowableFetchResult, sender: Network) {
        completion {
            return try result()
        }
    }
    public func didReceiveResult(_ result: () throws -> Network.FetchResult,
                                 from request: URLRequest, sender: Network) {}
}

open class Network {

    // MARK: Types

    public typealias FetchResult = Fetcher.Result

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

    private var requestsInProgres = [URLRequest]()

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
                            completionQueue: DispatchQueue? = nil,
                            completion: @escaping Completion.ThrowableFetchResult) {
        trySendingRequest(request, completionQueue: completionQueue, completion: completion)
    }

    // MARK: Helpers

    private func trySendingRequest(_ request: URLRequest,
                                   completionQueue: DispatchQueue? = nil,
                                   completion: @escaping Completion.ThrowableFetchResult)
    {
        guard !requestsInProgres.contains(request) else {
            return
        }
        requestsInProgres.append(request)

        delegate?.didSendRequest(request, sender: self)

        dispatchRequest(request, completionQueue: completionQueue) { [weak self] (result) in
            if let strongSelf = self {
                if let index = strongSelf.requestsInProgres.index(of: request) {
                    strongSelf.requestsInProgres.remove(at: index)
                }
                strongSelf.delegate?.didReceiveResult(result, from: request, sender: strongSelf)
            }

            completion {
                return try result()
            }
        }
    }

    private func dispatchRequest(_ request: URLRequest,
                                 completionQueue: DispatchQueue? = nil,
                                 completion: @escaping Completion.ThrowableFetchResult)
    {
        performRequest(request) { (result) in
            if let queue = completionQueue {
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
            } else {
                completion {
                    return try result()
                }
            }
        }
    }

    private func performRequest(_ request: URLRequest, completion: @escaping Completion.ThrowableFetchResult) {
        do {
            let modifiedRequest = try delegate?.interceptRequest(request, sender: self)
            let finalRequest = modifiedRequest ?? request

            fetcher.sendRequest(finalRequest, completion: { [weak self] (result) in
                if let weakSelf = self, let delegate = weakSelf.delegate {
                    delegate.interceptResult(result, from: request, completion: completion, sender: weakSelf)
                } else {
                    completion {
                        return try result()
                    }
                }
            })
        } catch {
            completion {
                throw error
            }
        }
    }

}
