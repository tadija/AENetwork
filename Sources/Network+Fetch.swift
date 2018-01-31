/**
 *  https://github.com/tadija/AENetwork
 *  Copyright (c) Marko Tadić 2017-2018
 *  Licensed under the MIT license. See LICENSE file.
 */

import Foundation

extension Network {
    
    // MARK: API
    
    public func sendRequest(_ request: URLRequest, completion: @escaping Completion.ThrowableFetchResult) {
        fetchSession.dataTask(with: request) { [weak self] data, response, error in
            if error == nil, let response = response as? HTTPURLResponse, let data = data {
                self?.handleValidResponse(response, with: data, from: request, completion: completion)
            } else {
                self?.handleResponseError(error.unsafelyUnwrapped, from: request, completion: completion)
            }
        }.resume()
    }
    
    // MARK: Helpers
    
    private func handleValidResponse(_ response: HTTPURLResponse,
                                     with data: Data,
                                     from request: URLRequest,
                                     completion: Completion.ThrowableFetchResult) {
        let result = FetchResult(response: response, data: data)
        switch response.statusCode {
        case 200 ..< 300:
            completion {
                return result
            }
        default:
            completion {
                throw FetchError.badResponseCode(result)
            }
        }
    }
    
    private func handleResponseError(_ error: Swift.Error,
                                     from request: URLRequest,
                                     completion: @escaping Completion.ThrowableFetchResult) {
        let nsError = error as NSError
        if nsError.domain == NSURLErrorDomain && nsError.code == NSURLErrorNetworkConnectionLost {
            // Retry request because of the iOS bug - SEE: https://github.com/AFNetworking/AFNetworking/issues/2314
            sendRequest(request, completion: completion)
        } else {
            completion {
                throw error
            }
        }
    }
    
}

extension Network {
    
    public struct FetchResult {
        public let response: HTTPURLResponse
        public let data: Data
        
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
    
    public enum FetchError: Swift.Error, LocalizedError, CustomNSError {
        case badResponseCode(FetchResult)
        
        // MARK: LocalizedError
        
        public var errorDescription: String? {
            switch self {
            case .badResponseCode(let result):
                let code = result.response.statusCode
                let status = HTTPURLResponse.localizedString(forStatusCode: code).capitalized
                let text = "Request failed with status code: \(code) \(status)"
                return text
            }
        }
        
        // MARK: CustomNSError
        
        public static var errorDomain: String {
            return "net.tadija.AENetwork/Fetcher"
        }
        
        public var errorCode: Int {
            switch self {
            case .badResponseCode(let result):
                return result.response.statusCode
            }
        }
        
        public var errorUserInfo: [String : Any] {
            switch self {
            case .badResponseCode(let result):
                return ["result" : result]
            }
        }
    }
    
}
