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
    func send(_ apiRequest: APIRequest, completion: @escaping APIResponseCallback)
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

public typealias APIResponseResult = Result<APIResponse>
public typealias APIResponseCallback = ResultCallback<APIResponse>

// MARK: - Extensions

public extension APIClient {
    func urlRequest(for apiRequest: APIRequest) -> URLRequest {
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
    func send(_ apiRequest: APIRequest, completion: @escaping APIResponseCallback) {
        let request = urlRequest(for: apiRequest)
        request.send { (result) in
            completion(Fetcher.apiResponseResult(from: result))
        }
    }
}

public extension APIRequest {
    var headers: [String : String]? {
        return nil
    }
    var parameters: [String : Any]? {
        return nil
    }
    var cachePolicy: URLRequest.CachePolicy? {
        return nil
    }
}

public extension APIResponse {
    var statusCode: Int {
        return response.statusCode
    }
    var headers: [AnyHashable : Any] {
        return response.allHeaderFields
    }
    var dictionary: [String : Any]? {
        return try? toDictionary()
    }
    var array: [Any]? {
        return try? toArray()
    }

    func toDictionary() throws -> [String : Any] {
        return try data.toDictionary()
    }
    func toArray() throws -> [Any] {
        return try data.toArray()
    }
}

public extension APIResponse {
    var shortDescription: String {
        return "Request: \(request.shortDescription) | Response: \(response.shortDescription)"
    }
    var fullDescription: String {
        return "\(request.fullDescription)\n\(response.fullDescription)"
    }
}
