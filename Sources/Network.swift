/**
 *  https://github.com/tadija/AENetwork
 *  Copyright (c) Marko Tadić 2017-2018
 *  Licensed under the MIT license. See LICENSE file.
 */

import Foundation

public protocol NetworkDelegate: class {
    func willSkipRequest(_ request: URLRequest, sender: Network)
    func willSendRequest(_ request: URLRequest, sender: Network)
    func willReceiveResult(_ result: () throws -> Network.FetchResult,
                           from request: URLRequest, sender: Network)

    func interceptRequest(_ request: URLRequest, sender: Network) throws -> URLRequest
    func interceptResult(_ result: () throws -> Network.FetchResult, from request: URLRequest, sender: Network,
                         completion: @escaping Network.Completion.ThrowableFetchResult)
}

public extension NetworkDelegate {
    public func willSkipRequest(_ request: URLRequest, sender: Network) {}
    public func willSendRequest(_ request: URLRequest, sender: Network) {}
    public func willReceiveResult(_ result: () throws -> Network.FetchResult,
                                  from request: URLRequest, sender: Network) {}

    public func interceptRequest(_ request: URLRequest, sender: Network) throws -> URLRequest {
        return request
    }
    public func interceptResult(_ result: () throws -> Network.FetchResult, from request: URLRequest, sender: Network,
                                completion: @escaping Network.Completion.ThrowableFetchResult) {
        completion {
            return try result()
        }
    }
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

    private let backgroundQueue = DispatchQueue(label: "AENetwork.Network.backgroundQueue")
    private var completions = Array<[URLRequest : Network.Completion.ThrowableFetchResult]>()

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

    open func sendRequest(_ request: URLRequest,
                          addToQueue: Bool = true,
                          completionQueue: DispatchQueue = .main,
                          completion: @escaping Network.Completion.ThrowableFetchResult)
    {
        backgroundQueue.async { [unowned self] in
            self.performRequest(request, addToQueue: addToQueue,
                                completionQueue: completionQueue, completion: completion)
        }
    }

    // MARK: Helpers

    private func performRequest(_ request: URLRequest,
                                addToQueue: Bool,
                                completionQueue: DispatchQueue,
                                completion: @escaping Network.Completion.ThrowableFetchResult)
    {
        do {
            let finalRequest = try interceptedRequest(for: request)
            if addToQueue {
                queueRequest(finalRequest, completionQueue: completionQueue, completion: completion)
            } else {
                fetchRequest(finalRequest, completionQueue: completionQueue, completion: completion)
            }
        } catch {
            completionQueue.async {
                completion {
                    throw error
                }
            }
        }
    }

    private func queueRequest(_ request: URLRequest,
                              completionQueue: DispatchQueue,
                              completion: @escaping Network.Completion.ThrowableFetchResult)
    {
        guard completions.filter({ $0.keys.contains(request) }).count == 0 else {
            completions.append([request : completion])
            delegate?.willSkipRequest(request, sender: self)
            return
        }
        completions.append([request : completion])
        fetchRequest(request, completionQueue: backgroundQueue) { [unowned self] (result) in
            self.performAllWaitingCompletions(for: request, with: result, in: completionQueue)
        }
    }

    private func fetchRequest(_ request: URLRequest,
                              completionQueue: DispatchQueue,
                              completion: @escaping Network.Completion.ThrowableFetchResult)
    {
        delegate?.willSendRequest(request, sender: self)
        fetcher.sendRequest(request) { [unowned self] (result) in
            self.interceptedResult(with: result, from: request) { [unowned self] (finalResult) in
                self.delegate?.willReceiveResult(finalResult, from: request, sender: self)
                self.dispatchResult(finalResult, in: completionQueue, completion: completion)
            }
        }
    }

    private func interceptedRequest(for request: URLRequest) throws -> URLRequest {
        do {
            let modifiedRequest = try delegate?.interceptRequest(request, sender: self)
            let finalRequest = modifiedRequest ?? request
            return finalRequest
        } catch {
            throw error
        }
    }

    private func interceptedResult(with result: () throws -> Network.FetchResult,
                                   from request: URLRequest,
                                   completion: @escaping Network.Completion.ThrowableFetchResult)
    {
        if let delegate = delegate {
            delegate.interceptResult(result, from: request, sender: self, completion: completion)
        } else {
            completion {
                return try result()
            }
        }
    }

    private func performAllWaitingCompletions(for request: URLRequest,
                                              with result: () throws -> Network.FetchResult,
                                              in completionQueue: DispatchQueue)
    {
        let filtered = completions.filter({ $0.keys.contains(request) })
        let filteredCompletions = filtered.flatMap({ $0.values.first })
        filteredCompletions.forEach { [unowned self] (completion) in
            self.dispatchResult(result, in: completionQueue, completion: completion)
        }
        let remainingCompletions = completions.filter({ $0.keys.contains(request) == false })
        self.completions = remainingCompletions
    }

    private func dispatchResult(_ result: () throws -> FetchResult,
                                in queue: DispatchQueue,
                                completion: @escaping Completion.ThrowableFetchResult)
    {
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
