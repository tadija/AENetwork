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
         body: Any? = nil)
    {
        if let urlParameters = urlParameters, let urlWithParameters = url.addingParameters(urlParameters) {
            self.init(url: urlWithParameters)
        } else {
            self.init(url: url)
        }
        httpMethod = method.rawValue.capitalized
        allHTTPHeaderFields = headers
        httpBody = httpBody(with: body)
    }

    // MARK: API

    public func fetchData(with network: Network = .shared, completion: @escaping Completion.ThrowableData) {
        network.fetchData(with: self, completion: completion)
    }

    public func fetchDictionary(with network: Network = .shared, completion: @escaping Completion.ThrowableDictionary) {
        network.fetchDictionary(with: self, completion: completion)
    }

    public func fetchArray(with network: Network = .shared, completion: @escaping Completion.ThrowableArray) {
        network.fetchArray(with: self, completion: completion)
    }

    // MARK: Helpers

    private func httpBody(with any: Any?) -> Data? {
        guard
            let any = any,
            let jsonData = try? JSONSerialization.data(withJSONObject: any, options: .prettyPrinted)
        else {
            return nil
        }
        return jsonData
    }

}
