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

    func interceptRequest(_ request: URLRequest, sender: Network) throws -> URLRequest
    func interceptResult(_ result: () throws -> Network.FetchResult, from request: URLRequest, sender: Network,
                         completion: @escaping Network.Completion.ThrowableFetchResult)
}

public extension NetworkDelegate {
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

    private var operations = Array<[URLRequest : Network.Completion.ThrowableFetchResult]>()

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
                          preventIfDuplicate: Bool = true,
                          completionQueue: DispatchQueue = .main,
                          completion: @escaping Network.Completion.ThrowableFetchResult)
    {
        do {
            let finalRequest = try interceptedRequest(for: request)

            if preventIfDuplicate {
                guard operations.filter({ $0.keys.contains(finalRequest) }).count == 0 else {
                    operations.append([finalRequest : completion])
                    return
                }
                operations.append([finalRequest : completion])
            }

            delegate?.willSendRequest(request, sender: self)
            fetcher.sendRequest(finalRequest) { [unowned self] (result) in
                self.interceptedResult(with: result, from: finalRequest) { (finalResult) in
                    self.delegate?.willReceiveResult(finalResult, from: request, sender: self)
                    self.returnResult(finalResult, in: completionQueue) { (endResult) in
                        if preventIfDuplicate {
                            self.performAllWaitingOperations(for: finalRequest, with: endResult)
                        } else {
                            completion {
                                return try endResult()
                            }
                        }
                    }
                }
            }
        } catch {
            completion {
                throw error
            }
        }
    }

    // MARK: Helpers

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

    private func performAllWaitingOperations(for request: URLRequest, with result: () throws -> Network.FetchResult) {
        let f = self.operations.filter({ $0.keys.contains(request) })
        let v = f.flatMap({ $0.values.first })
        v.forEach({ $0{ return try result() } })
        let nf = self.operations.filter({ $0.keys.contains(request) == false })
        self.operations = nf
    }

}
