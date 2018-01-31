/**
 *  https://github.com/tadija/AENetwork
 *  Copyright (c) Marko Tadić 2017-2018
 *  Licensed under the MIT license. See LICENSE file.
 */

import Foundation

extension Network {
    
    // MARK: API
    
    open func fetchRequest(_ request: URLRequest,
                          addToQueue: Bool = true,
                          completionQueue: DispatchQueue = .main,
                          completion: @escaping Network.Completion.ThrowableFetchResult)
    {
        fetchQueue.async { [unowned self] in
            self.performRequest(request, addToQueue: addToQueue,
                                completionQueue: completionQueue, completion: completion)
        }
    }
    
    // MARK: Helpers
    
    private func performRequest(_ request: URLRequest,
                                addToQueue: Bool,
                                completionQueue: DispatchQueue,
                                completion: @escaping Network.Completion.ThrowableFetchResult)
    {
        do {
            let finalRequest = try interceptedRequest(for: request)
            if addToQueue {
                queueRequest(finalRequest, completionQueue: completionQueue, completion: completion)
            } else {
                sendRequest(finalRequest, completionQueue: completionQueue, completion: completion)
            }
        } catch {
            completionQueue.async {
                completion {
                    throw error
                }
            }
        }
    }
    
    private func queueRequest(_ request: URLRequest,
                              completionQueue: DispatchQueue,
                              completion: @escaping Network.Completion.ThrowableFetchResult)
    {
        guard fetchCompletions.filter({ $0.keys.contains(request) }).count == 0 else {
            fetchCompletions.append([request : completion])
            fetchDelegate?.willSkipRequest(request, sender: self)
            return
        }
        fetchCompletions.append([request : completion])
        sendRequest(request, completionQueue: fetchQueue) { [unowned self] (result) in
            self.performAllWaitingCompletions(for: request, with: result, in: completionQueue)
        }
    }
    
    private func sendRequest(_ request: URLRequest,
                              completionQueue: DispatchQueue,
                              completion: @escaping Network.Completion.ThrowableFetchResult)
    {
        fetchDelegate?.willSendRequest(request, sender: self)
        resumeDataTask(with: request) { [unowned self] (result) in
            self.interceptedResult(with: result, from: request) { [unowned self] (finalResult) in
                self.fetchDelegate?.willReceiveResult(finalResult, from: request, sender: self)
                self.dispatchResult(finalResult, in: completionQueue, completion: completion)
            }
        }
    }
    
    private func interceptedRequest(for request: URLRequest) throws -> URLRequest {
        do {
            let modifiedRequest = try fetchDelegate?.interceptRequest(request, sender: self)
            let finalRequest = modifiedRequest ?? request
            return finalRequest
        } catch {
            throw error
        }
    }
    
    private func interceptedResult(with result: () throws -> Network.FetchResult,
                                   from request: URLRequest,
                                   completion: @escaping Network.Completion.ThrowableFetchResult)
    {
        if let delegate = fetchDelegate {
            delegate.interceptResult(result, from: request, sender: self, completion: completion)
        } else {
            completion {
                return try result()
            }
        }
    }
    
    private func performAllWaitingCompletions(for request: URLRequest,
                                              with result: () throws -> Network.FetchResult,
                                              in completionQueue: DispatchQueue)
    {
        let filtered = fetchCompletions.filter({ $0.keys.contains(request) })
        let filteredCompletions = filtered.flatMap({ $0.values.first })
        filteredCompletions.forEach { [unowned self] (completion) in
            self.dispatchResult(result, in: completionQueue, completion: completion)
        }
        let remainingCompletions = fetchCompletions.filter({ $0.keys.contains(request) == false })
        self.fetchCompletions = remainingCompletions
    }
    
    private func dispatchResult(_ result: () throws -> FetchResult,
                                in queue: DispatchQueue,
                                completion: @escaping Completion.ThrowableFetchResult)
    {
        do {
            let result = try result()
            queue.async {
                completion {
                    return result
                }
            }
        } catch {
            queue.async {
                completion {
                    throw error
                }
            }
        }
    }
    
}

extension Network {
    
    // MARK: Data Task
    
    fileprivate func resumeDataTask(with request: URLRequest, completion: @escaping Completion.ThrowableFetchResult) {
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
            resumeDataTask(with: request, completion: completion)
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
