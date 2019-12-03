/**
 *  https://github.com/tadija/AENetwork
 *  Copyright (c) Marko Tadić 2017-2019
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
    var body: Data? { get }
    var cachePolicy: URLRequest.CachePolicy? { get }

    var useMockResponse: Bool { get }
    var mockData: Data? { get }
    var mockResponse: APIResponse? { get }
}

public protocol APIResponse {
    var request: URLRequest { get }
    var response: HTTPURLResponse { get }
    var data: Data { get }
}

public typealias ResultCallback<T> = (Result<T, Error>) -> Void
public typealias APIResponseResult = Result<APIResponse, Error>
public typealias APIResponseCallback = ResultCallback<APIResponse>

// MARK: - Extensions

public extension APIClient {
    func urlRequest(for apiRequest: APIRequest) -> URLRequest {
        let url = baseURL.appendingPathComponent(apiRequest.path)
        var request: URLRequest
        
        switch apiRequest.method {
        case .get:
            request = URLRequest.get(
                url: url,
                headers: apiRequest.headers,
                urlParameters: apiRequest.parameters
            )
        case .post:
            request = URLRequest.post(
                url: url,
                headers: apiRequest.headers,
                body: apiRequest.body
            )
        case .put:
            request = URLRequest.put(
                url: url,
                headers: apiRequest.headers,
                body: apiRequest.body
            )
        case .patch:
            request = URLRequest.patch(
                url: url,
                headers: apiRequest.headers,
                body: apiRequest.body
            )
        case .delete:
            request = URLRequest.delete(
                url: url,
                headers: apiRequest.headers,
                body: apiRequest.body
            )
        }
        
        if let cachePolicy = apiRequest.cachePolicy {
            request.cachePolicy = cachePolicy
        }
        
        return request
    }

    func send(_ apiRequest: APIRequest, completion: @escaping APIResponseCallback) {
        let request = urlRequest(for: apiRequest)
        if let mockResponse = apiRequest.mockResponse {
            completion(.success(mockResponse))
        } else {
            request.send { (result) in
                completion(Fetcher.apiResponseResult(from: result))
            }
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
    var body: Data? {
        guard
            let parameters = parameters,
            let json = try? Data(jsonWith: parameters) else {
            return nil
        }
        return json
    }
    var cachePolicy: URLRequest.CachePolicy? {
        return nil
    }
}

public extension APIRequest {
    var useMockResponse: Bool {
        return false
    }
    var mockData: Data? {
        return nil
    }
    var mockResponse: APIResponse? {
        guard useMockResponse,
            let mockData = mockData else {
                return nil
        }
        return Fetcher.Response(
            request: URLRequest(url: URL.mocked),
            response: HTTPURLResponse(),
            data: mockData
        )
    }
}

public extension APIResponse {
    var statusCode: Int {
        return response.statusCode
    }
    var headers: [AnyHashable : Any] {
        return response.allHeaderFields
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
