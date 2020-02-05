/**
 *  https://github.com/tadija/AENetwork
 *  Copyright © 2017-2020 Marko Tadić
 *  Licensed under the MIT license
 */

import Foundation

// MARK: - Factory

public extension URLRequest {

    enum Method: String {
        case get, post, put, patch, delete
    }

    init(url: URL,
         method: Method,
         headers: [String: String]? = nil,
         urlParameters: [String: Any]? = nil,
         body: Data? = nil)
    {
        if
            let urlParameters = urlParameters,
            let urlWithParameters = url.addingParameters(urlParameters)
        {
            self.init(url: urlWithParameters)
        } else {
            self.init(url: url)
        }
        httpMethod = method.rawValue.uppercased()
        allHTTPHeaderFields = headers
        if let body = body {
            httpBody = body
        }
    }

    static func get(url: URL,
                    headers: [String: String]? = nil,
                    urlParameters: [String: Any]? = nil) -> URLRequest {
        URLRequest(
            url: url,
            method: .get,
            headers: headers,
            urlParameters: urlParameters
        )
    }

    static func post(url: URL,
                     headers: [String: String]? = nil,
                     body: Data? = nil) -> URLRequest {
        URLRequest(
            url: url,
            method: .post,
            headers: headers,
            body: body
        )
    }

    static func put(url: URL,
                    headers: [String: String]? = nil,
                    body: Data? = nil) -> URLRequest {
        URLRequest(
            url: url,
            method: .put,
            headers: headers,
            body: body
        )
    }

    static func patch(url: URL,
                      headers: [String: String]? = nil,
                      body: Data? = nil) -> URLRequest {
        URLRequest(
            url: url,
            method: .patch,
            headers: headers,
            body: body
        )
    }

    static func delete(url: URL,
                       headers: [String: String]? = nil,
                       body: Data? = nil) -> URLRequest {
        URLRequest(
            url: url,
            method: .delete,
            headers: headers,
            body: body
        )
    }

}

// MARK: - Description

public extension URLRequest {
    var shortDescription: String {
        let method = (httpMethod ?? "N/A").uppercased()
        let url = self.url?.absoluteString ?? "n/a"
        return "\(method) \(url)"
    }
    var fullDescription: String {
        let headers = "\(allHTTPHeaderFields ?? [:])"
        let parameters = "\(url?.parameters ?? [:])"
        let body = (try? httpBody?.jsonDictionary()) ?? [:]
        return """
        - Request: \(shortDescription)
        - Headers: \(headers)
        - Parameters: \(parameters)
        - Body: \(body)
        """
    }
}

// MARK: - Custom Equatable

public extension URLRequest {
    func isEqual(to request: URLRequest?) -> Bool {
        self == request && self.httpBody == request?.httpBody
    }
}
