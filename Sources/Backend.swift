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

public protocol Backend: class {
    var api: BackendAPI { get }
    var network: Network { get }
    var queue: DispatchQueue { get }

    func sendRequest(_ backendRequest: BackendRequest,
                     preventIfDuplicate: Bool,
                     completionQueue: DispatchQueue,
                     completion: @escaping Network.Completion.ThrowableFetchResult)
}

public extension Backend {
    public func sendRequest(_ backendRequest: BackendRequest,
                            preventIfDuplicate: Bool = true,
                            completionQueue: DispatchQueue = .main,
                            completion: @escaping Network.Completion.ThrowableFetchResult) {
        queue.async { [unowned self] in
            let request = self.api.createURLRequest(from: backendRequest)
            self.network.sendRequest(request, preventIfDuplicate: preventIfDuplicate,
                                completionQueue: completionQueue, completion: completion)
        }
    }
}
