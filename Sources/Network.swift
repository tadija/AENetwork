//
// Network.swift
//
// Copyright (c) 2017 Marko Tadić <tadija@me.com> http://tadija.net
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

import Foundation

public protocol NetworkCacheDelegate: class {
    func shouldCacheResponse(from request: URLRequest) -> Bool
    func isValidCache(_ cache: CachedURLResponse) -> Bool
}

public class Network {
    
    // MARK: - Types
    
    public enum NetworkError: Error {
        case badResponse
        case parsingFailed
    }
    
    // MARK: - Singleton
    
    public static let shared = Network()
    
    // MARK: - Init
    
    public init() {}
    
    // MARK: - Properties
    
    public weak var cacheDelegate: NetworkCacheDelegate?
    
    // MARK: - Request / Response
    
    internal func sendRequest(_ request: URLRequest, completion: @escaping ThrowDataInClosure) {
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let
                httpResponse = response as? HTTPURLResponse,
                let responseData = data
            {
                self.handleResponse(httpResponse, with: responseData, from: request, completion: completion)
            } else {
                self.handleResponseError(error, from: request, completion: completion)
            }
        }.resume()
        
    }
    
    private func handleResponse(_ response: HTTPURLResponse,
                                with data: Data,
                                from request: URLRequest,
                                completion: ThrowDataInClosure) {
        
        switch response.statusCode {
        case 200:
            if let delegate = self.cacheDelegate, delegate.shouldCacheResponse(from: request) {
                self.cacheResponse(response, with: data, from: request)
            }
            completion {
                return data
            }
        default:
            completion {
                throw NetworkError.badResponse
            }
        }
        
    }
    
    private func handleResponseError(_ error: Error?,
                                     from request: URLRequest,
                                     completion: @escaping ThrowDataInClosure) {
        
        if let responseError = error as NSError? {
            if responseError.domain == NSURLErrorDomain && responseError.code == NSURLErrorNetworkConnectionLost {
                // Retry request because of the iOS bug - SEE: https://github.com/AFNetworking/AFNetworking/issues/2314
                self.fetchData(with: request, completion: completion)
            } else {
                completion {
                    throw responseError
                }
            }
        } else {
            completion {
                throw NetworkError.badResponse
            }
        }
        
    }
    
}
