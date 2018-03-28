/**
 *  https://github.com/tadija/AENetwork
 *  Copyright (c) Marko Tadić 2017-2018
 *  Licensed under the MIT license. See LICENSE file.
 */

import Foundation

// MARK: - Protocols

public protocol APIClient {
    var baseURL: URL { get }
    func urlRequest(for apiRequest: APIRequest) -> URLRequest
    func send(_ apiRequest: APIRequest, completion: @escaping ResultCallback<APIResponse>)
}

public protocol APIRequest {
    var method: URLRequest.Method { get }
    var path: String { get }
    var headers: [String : String]? { get }
    var parameters: [String : Any]? { get }
    var cachePolicy: URLRequest.CachePolicy? { get }
}

public protocol APIResponse {
    var request: URLRequest { get }
    var response: HTTPURLResponse { get }
    var data: Data { get }
}

// MARK: - Extensions

public extension APIClient {
    public func urlRequest(for apiRequest: APIRequest) -> URLRequest {
        let url = baseURL.appendingPathComponent(apiRequest.path)
        var request: URLRequest
        
        switch apiRequest.method {
        case .get:
            request = URLRequest.get(url: url, headers: apiRequest.headers, parameters: apiRequest.parameters)
        case .post:
            request = URLRequest.post(url: url, headers: apiRequest.headers, parameters: apiRequest.parameters)
        case .put:
            request = URLRequest.put(url: url, headers: apiRequest.headers, parameters: apiRequest.parameters)
        case .delete:
            request = URLRequest.delete(url: url, headers: apiRequest.headers, parameters: apiRequest.parameters)
        }
        
        if let cachePolicy = apiRequest.cachePolicy {
            request.cachePolicy = cachePolicy
        }
        
        return request
    }
}

public extension APIRequest {
    public var headers: [String : String]? {
        return nil
    }
    public var parameters: [String : Any]? {
        return nil
    }
    public var cachePolicy: URLRequest.CachePolicy? {
        return nil
    }
}

public extension APIResponse {
    public var statusCode: Int {
        return response.statusCode
    }
    public var headers: [AnyHashable : Any] {
        return response.allHeaderFields
    }
    public var dictionary: [String : Any]? {
        return try? toDictionary()
    }
    public var array: [Any]? {
        return try? toArray()
    }

    public func toDictionary() throws -> [String : Any] {
        return try data.toDictionary()
    }
    public func toArray() throws -> [Any] {
        return try data.toArray()
    }
}

public extension APIResponse {
    public var shortDescription: String {
        return "Request: \(request.shortDescription) | Response: \(response.shortDescription)"
    }
    public var fullDescription: String {
        return "\(request.fullDescription)\n\(response.fullDescription)"
    }
}
