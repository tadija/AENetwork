/**
 *  https://github.com/tadija/AENetwork
 *  Copyright (c) Marko Tadić 2017
 *  Licensed under the MIT license. See LICENSE file.
 */

import Foundation

public protocol Backend: class {
    var baseURL: URL { get }

    var network: Network { get }
    var backgroundQueue: DispatchQueue { get }

    func createURLRequest(from backendRequest: BackendRequest) -> URLRequest
    func sendRequest(_ backendRequest: BackendRequest,
                     addRequestToQueue: Bool,
                     completionQueue: DispatchQueue,
                     completion: @escaping Network.Completion.ThrowableFetchResult)
}

public extension Backend {
    var network: Network {
        return Network.shared
    }
    var backgroundQueue: DispatchQueue {
        return DispatchQueue.global()
    }

    public func createURLRequest(from backendRequest: BackendRequest) -> URLRequest {
        return URLRequest(baseURL: baseURL, backendRequest: backendRequest)
    }
    public func sendRequest(_ backendRequest: BackendRequest,
                            addRequestToQueue: Bool = true,
                            completionQueue: DispatchQueue = .main,
                            completion: @escaping Network.Completion.ThrowableFetchResult) {
        backgroundQueue.async { [unowned self] in
            let request = self.createURLRequest(from: backendRequest)
            self.network.sendRequest(request, addRequestToQueue: addRequestToQueue,
                                completionQueue: completionQueue, completion: completion)
        }
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
