/**
 *  https://github.com/tadija/AENetwork
 *  Copyright (c) Marko Tadić 2017-2018
 *  Licensed under the MIT license. See LICENSE file.
 */

import Foundation

public protocol NetworkFetchDelegate: class {
    func willSkipRequest(_ request: URLRequest, sender: Network)
    func willSendRequest(_ request: URLRequest, sender: Network)
    func willReceiveResult(_ result: () throws -> Network.FetchResult,
                           from request: URLRequest, sender: Network)

    func interceptRequest(_ request: URLRequest, sender: Network) throws -> URLRequest
    func interceptResult(_ result: () throws -> Network.FetchResult, from request: URLRequest, sender: Network,
                         completion: @escaping Network.Completion.ThrowableFetchResult)
}

public extension NetworkFetchDelegate {
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
    
    public struct FetchResult {
        public let response: HTTPURLResponse
        public let data: Data
    }
    
    public enum FetchError: Error {
        case badResponseCode(FetchResult)
    }

    public struct Completion {
        public typealias ThrowableFetchResult = (() throws -> FetchResult) -> Void
    }
    
    // MARK: Singleton
    
    public static let shared = Network()

    // MARK: Properties

    public weak var fetchDelegate: NetworkFetchDelegate?
    
    public let fetchSession: URLSession
    public let reachability: Reachability

    internal let fetchQueue = DispatchQueue(label: "AENetwork.Network.fetchQueue")
    internal var fetchCompletions = Array<[URLRequest : Completion.ThrowableFetchResult]>()

    // MARK: Init
    
    public init(fetchSession: URLSession = .shared,
                reachability: Reachability = .shared)
    {
        self.fetchSession = fetchSession
        self.reachability = reachability
    }

}
