/**
 *  https://github.com/tadija/AENetwork
 *  Copyright (c) Marko Tadić 2017
 *  Licensed under the MIT license. See LICENSE file.
 */

import Foundation

public protocol BackendRequest {
    var method: URLRequest.Method { get }
    var endpoint: String { get }
    var headers: [String : String]? { get }
    var parameters: [String : Any]? { get }
}

public extension BackendRequest {
    var headers: [String : String]? {
        return nil
    }
    var parameters: [String : Any]? {
        return nil
    }
}

public protocol BackendAPI {
    var baseURL: URL { get }
    func createURLRequest(from backendRequest: BackendRequest) -> URLRequest
}

public extension BackendAPI {
    public func createURLRequest(from backendRequest: BackendRequest) -> URLRequest {
        return URLRequest(baseURL: baseURL, backendRequest: backendRequest)
    }
}

public protocol Backend {
    var api: BackendAPI { get }
    var network: Network { get }

    func sendRequest(_ backendRequest: BackendRequest,
                     completionQueue: DispatchQueue?,
                     completion: @escaping Network.Completion.ThrowableFetchResult)
    
    func sendRequest(_ backendRequest: BackendRequest,
                     completionQueue: DispatchQueue?,
                     completion: @escaping Network.Completion.FailableFetchResult)
}

public extension Backend {
    public func sendRequest(_ backendRequest: BackendRequest,
                            completionQueue: DispatchQueue? = nil,
                            completion: @escaping Network.Completion.ThrowableFetchResult) {
        let request = api.createURLRequest(from: backendRequest)
        network.sendRequest(request, completionQueue: completionQueue, completion: completion)
    }

    public func sendRequest(_ backendRequest: BackendRequest,
                            completionQueue: DispatchQueue? = nil,
                            completion: @escaping Network.Completion.FailableFetchResult) {
        let request = api.createURLRequest(from: backendRequest)
        network.sendRequest(request, completionQueue: completionQueue, completion: completion)
    }
}
