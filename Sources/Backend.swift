/**
 *  https://github.com/tadija/AENetwork
 *  Copyright (c) Marko Tadić 2017
 *  Licensed under the MIT license. See LICENSE file.
 */

import Foundation

public protocol BackendAPI {
    var baseURL: URL { get }
    func createURLRequest(from backendRequest: BackendRequest) -> URLRequest
}

public extension BackendAPI {
    public func createURLRequest(from backendRequest: BackendRequest) -> URLRequest {
        return URLRequest(baseURL: baseURL, backendRequest: backendRequest)
    }
}

public protocol BackendRequest {
    var method: URLRequest.Method { get }
    var endpoint: String { get }
    var cachePolicy: URLRequest.CachePolicy? { get }
    var headers: [String : String]? { get }
    var parameters: [String : Any]? { get }
}

public extension BackendRequest {
    var cachePolicy: URLRequest.CachePolicy? {
        return nil
    }
    var headers: [String : String]? {
        return nil
    }
    var parameters: [String : Any]? {
        return nil
    }
}

open class Backend {
    public let api: BackendAPI
    public let network: Network

    public init(api: BackendAPI, network: Network) {
        self.api = api
        self.network = network
    }

    open func sendRequest(_ backendRequest: BackendRequest,
                     completionQueue: DispatchQueue?,
                     completion: @escaping Network.Completion.ThrowableFetchResult) {
        let request = api.createURLRequest(from: backendRequest)
        network.sendRequest(request, completionQueue: completionQueue, completion: completion)
    }
}
