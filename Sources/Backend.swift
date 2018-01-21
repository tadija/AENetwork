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
    func interceptRequest(_ request: BackendRequest, sender: Backend) throws -> BackendRequest
    func interceptResult(_ result: () throws -> Network.FetchResult, from request: BackendRequest,
                         completion: @escaping Network.Completion.ThrowableFetchResult, sender: Backend)
}

public extension BackendDelegate {
    public func interceptRequest(_ request: BackendRequest, sender: Backend) throws -> BackendRequest {
        return request
    }
    public func interceptResult(_ result: () throws -> Network.FetchResult, from request: BackendRequest,
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

    private var operations = Array<[URLRequest : Network.Completion.ThrowableFetchResult]>()

    public init(api: BackendAPI, network: Network) {
        self.api = api
        self.network = network
    }

    open func sendRequest(_ request: BackendRequest,
                          preventIfDuplicate: Bool = true,
                          completionQueue: DispatchQueue = .main,
                          completion: @escaping Network.Completion.ThrowableFetchResult)
    {
        do {
            let finalRequest = try interceptedRequest(for: request)
            let urlRequest = api.createURLRequest(from: finalRequest)

            if preventIfDuplicate {
                guard operations.filter({ $0.keys.contains(urlRequest) }).count == 0 else {
                    operations.append([urlRequest : completion])
                    return
                }
                operations.append([urlRequest : completion])
            }

            network.sendRequest(urlRequest, completionQueue: completionQueue) { [unowned self] (result) in
                self.interceptedResult(with: result, from: request) { (finalResult) in
                    if preventIfDuplicate {
                        self.performAllWaitingOperations(for: urlRequest, with: finalResult)
                    } else {
                        completion {
                            return try finalResult()
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

    private func interceptedRequest(for request: BackendRequest) throws -> BackendRequest {
        do {
            let modifiedRequest = try delegate?.interceptRequest(request, sender: self)
            let finalRequest = modifiedRequest ?? request
            return finalRequest
        } catch {
            throw error
        }
    }

    private func interceptedResult(with result: () throws -> Network.FetchResult,
                                   from request: BackendRequest,
                                   completion: @escaping Network.Completion.ThrowableFetchResult)
    {
        if let delegate = delegate {
            delegate.interceptResult(result, from: request, completion: completion, sender: self)
        } else {
            completion {
                return try result()
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
