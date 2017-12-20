/**
 *  https://github.com/tadija/AENetwork
 *  Copyright (c) Marko Tadić 2017
 *  Licensed under the MIT license. See LICENSE file.
 */

import Foundation

extension URLRequest {

    // MARK: Types

    public enum Method: String {
        case get, post, put, delete
    }

    // MARK: Init

    init(url: URL,
         method: Method,
         headers: [String : String]? = nil,
         urlParameters: [String : String]? = nil,
         body: [String : String]? = nil)
    {
        if let urlParameters = urlParameters, let urlWithParameters = url.addingParameters(urlParameters) {
            self.init(url: urlWithParameters)
        } else {
            self.init(url: url)
        }
        httpMethod = method.rawValue.capitalized
        allHTTPHeaderFields = headers
        if let body = body {
            httpBody = try? Data(jsonWith: body)
        }
    }

    // MARK: API / Factory

    static func get(url: URL, headers: [String : String]? = nil, parameters: [String : String]? = nil) -> URLRequest {
        return URLRequest(url: url, method: .get, headers: headers, urlParameters: parameters)
    }

    static func post(url: URL, headers: [String : String]? = nil, parameters: [String : String]? = nil) -> URLRequest {
        return URLRequest(url: url, method: .post, headers: headers, body: parameters)
    }

    static func put(url: URL, headers: [String : String]? = nil, parameters: [String : String]? = nil) -> URLRequest {
        return URLRequest(url: url, method: .put, headers: headers, body: parameters)
    }

    static func delete(url: URL, headers: [String : String]? = nil, parameters: [String : String]? = nil) -> URLRequest {
        return URLRequest(url: url, method: .delete, headers: headers, body: parameters)
    }

    // MARK: API / Fetch

    public func fetchData(with network: Network = .shared, completion: @escaping Completion.ThrowableData) {
        network.fetchData(with: self, completion: completion)
    }

    public func fetchData(with network: Network = .shared, completion: @escaping Completion.FailableData) {
        network.fetchData(with: self, completion: completion)
    }

    public func fetchDictionary(with network: Network = .shared, completion: @escaping Completion.ThrowableDictionary) {
        network.fetchDictionary(with: self, completion: completion)
    }

    public func fetchDictionary(with network: Network = .shared, completion: @escaping Completion.FailableDictionary) {
        network.fetchDictionary(with: self, completion: completion)
    }

    public func fetchArray(with network: Network = .shared, completion: @escaping Completion.ThrowableArray) {
        network.fetchArray(with: self, completion: completion)
    }

    public func fetchArray(with network: Network = .shared, completion: @escaping Completion.FailableArray) {
        network.fetchArray(with: self, completion: completion)
    }

}
