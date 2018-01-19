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

public protocol BackendDelegate: class {
    func interceptRequest(_ request: URLRequest, sender: Backend) throws -> URLRequest
    func interceptResult(_ result: () throws -> Network.FetchResult, from request: URLRequest,
                         completion: @escaping Network.Completion.ThrowableFetchResult, sender: Backend)
}

public extension BackendDelegate {
    public func interceptRequest(_ request: URLRequest, sender: Backend) throws -> URLRequest {
        return request
    }
    public func interceptResult(_ result: () throws -> Network.FetchResult, from request: URLRequest,
                                completion: @escaping Network.Completion.ThrowableFetchResult, sender: Backend) {
        completion {
            return try result()
        }
    }
}

open class Backend {
    public weak var delegate: BackendDelegate?

    public let api: BackendAPI
    public let network: Network

    public init(api: BackendAPI, network: Network) {
        self.api = api
        self.network = network
    }

    open func sendRequest(_ backendRequest: BackendRequest,
                     completionQueue: DispatchQueue = .main,
                     completion: @escaping Network.Completion.ThrowableFetchResult)
    {
        let request = api.createURLRequest(from: backendRequest)
        
        do {
            let modifiedRequest = try delegate?.interceptRequest(request, sender: self)
            let finalRequest = modifiedRequest ?? request

            network.sendRequest(finalRequest, completionQueue: completionQueue) { [unowned self] (result) in
                if let delegate = self.delegate {
                    delegate.interceptResult(result, from: request, completion: completion, sender: self)
                } else {
                    completion {
                        return try result()
                    }
                }
            }
        } catch {
            completion {
                throw error
            }
        }
    }

}
