/**
 *  https://github.com/tadija/AENetwork
 *  Copyright (c) Marko Tadić 2017
 *  Licensed under the MIT license. See LICENSE file.
 */

import Foundation

public protocol Backend {
    var baseURL: URL { get }
    var network: Network { get }
    
    func createURLRequest(from backendRequest: BackendRequest) -> URLRequest
    func performRequest(_ backendRequest: BackendRequest, completion: @escaping Fetcher.Completion.ThrowableResult)
}

public extension Backend {
    public func createURLRequest(from backendRequest: BackendRequest) -> URLRequest {
        return URLRequest(baseURL: baseURL, backendRequest: backendRequest)
    }
    public func performRequest(_ backendRequest: BackendRequest, completion: @escaping Fetcher.Completion.ThrowableResult) {
        let request = createURLRequest(from: backendRequest)
        network.performRequest(request, completion: completion)
    }
}

public protocol BackendRequest {
    var method: URLRequest.Method { get }
    var endpoint: String { get }
    var headers: [String : String]? { get }
    var parameters: [String : Any]? { get }
}
