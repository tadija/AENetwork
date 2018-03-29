/**
 *  https://github.com/tadija/AENetwork
 *  Copyright (c) Marko Tadić 2017-2018
 *  Licensed under the MIT license. See LICENSE file.
 */

import Foundation

// MARK: - FetcherDelegate

public protocol FetcherDelegate: class {
    func willSkipRequest(_ request: URLRequest, sender: Fetcher)
    func willSendRequest(_ request: URLRequest, sender: Fetcher)
    func willReceiveResult(_ result: Fetcher.ResponseResult, sender: Fetcher)
    
    func interceptRequest(_ request: URLRequest, sender: Fetcher) throws -> URLRequest
    func interceptResult(_ result: Fetcher.ResponseResult, sender: Fetcher, completion: @escaping Fetcher.Callback)
}

public extension FetcherDelegate {
    public func willSkipRequest(_ request: URLRequest, sender: Fetcher) {}
    public func willSendRequest(_ request: URLRequest, sender: Fetcher) {}
    public func willReceiveResult(_ result: Fetcher.ResponseResult, sender: Fetcher) {}

    public func interceptRequest(_ request: URLRequest, sender: Fetcher) throws -> URLRequest {
        return request
    }
    public func interceptResult(_ result: Fetcher.ResponseResult, sender: Fetcher,
                                completion: @escaping Fetcher.Callback) {
        completion(result)
    }
}

// MARK: - Fetcher

open class Fetcher {
    
    // MARK: Types

    public struct Response: APIResponse {
        public let request: URLRequest
        public let response: HTTPURLResponse
        public let data: Data
    }

    public enum Error: Swift.Error {
        case invalidResponse(Response)
    }

    public typealias ResponseResult = Result<Response>
    public typealias Callback = ResultCallback<Response>
    
    // MARK: Properties
    
    public weak var delegate: FetcherDelegate?
    
    private let session: URLSession
    private let queue = DispatchQueue(label: "AENetwork.Fetcher.Queue")
    private var callbacks = Array<[URLRequest : Callback]>()
    
    // MARK: Init
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    // MARK: API
    
    public func send(_ request: URLRequest, completion: @escaping Callback) {
        queue.async { [unowned self] in
            self.handleRequest(request, addToQueue: true, completion: completion)
        }
    }

    public func forceSend(_ request: URLRequest, completion: @escaping Callback) {
        queue.async { [unowned self] in
            self.handleRequest(request, addToQueue: false, completion: completion)
        }
    }
    
    // MARK: Helpers
    
    private func handleRequest(_ request: URLRequest, addToQueue: Bool, completion: @escaping Callback) {
        do {
            let finalRequest = try interceptedRequest(for: request)
            if addToQueue {
                queueRequest(finalRequest, completion: completion)
            } else {
                performRequest(finalRequest, completion: completion)
            }
        } catch {
            dispatchResult(.failure(error), completion: completion)
        }
    }
    
    private func queueRequest(_ request: URLRequest, completion: @escaping Callback) {
        guard callbacks.filter({ $0.keys.contains(request) }).count == 0 else {
            callbacks.append([request : completion])
            delegate?.willSkipRequest(request, sender: self)
            return
        }
        callbacks.append([request : completion])
        performRequest(request) { [unowned self] (result) in
            self.performAllCallbacks(for: request, with: result)
        }
    }
    
    private func performRequest(_ request: URLRequest, completion: @escaping Callback) {
        delegate?.willSendRequest(request, sender: self)
        resumeDataTask(with: request) { [unowned self] (result) in
            self.interceptedResult(result) { [unowned self] (finalResult) in
                self.delegate?.willReceiveResult(finalResult, sender: self)
                self.dispatchResult(finalResult, completion: completion)
            }
        }
    }
    
    private func interceptedRequest(for request: URLRequest) throws -> URLRequest {
        do {
            let modifiedRequest = try delegate?.interceptRequest(request, sender: self)
            let finalRequest = modifiedRequest ?? request
            return finalRequest
        } catch {
            throw error
        }
    }
    
    private func interceptedResult(_ result: ResponseResult, completion: @escaping Callback) {
        if let delegate = delegate {
            delegate.interceptResult(result, sender: self, completion: completion)
        } else {
            return completion(result)
        }
    }
    
    private func performAllCallbacks(for request: URLRequest, with result: ResponseResult) {
        let filtered = callbacks.filter({ $0.keys.contains(request) }).flatMap({ $0.values.first })
        filtered.forEach { [unowned self] (completion) in
            self.dispatchResult(result, completion: completion)
        }
        let remaining = callbacks.filter({ $0.keys.contains(request) == false })
        self.callbacks = remaining
    }
    
    private func dispatchResult(_ result: ResponseResult, completion: @escaping Callback) {
        DispatchQueue.main.async {
            completion(result)
        }
    }
    
    private func resumeDataTask(with request: URLRequest, completion: @escaping Callback) {
        session.dataTask(with: request) { [weak self] data, response, error in
            if error == nil, let response = response as? HTTPURLResponse, let data = data {
                self?.handleValidResponse(response, with: data, from: request, completion: completion)
            } else {
                self?.handleErrorResponse(error.unsafelyUnwrapped, from: request, completion: completion)
            }
        }.resume()
    }
    
    private func handleValidResponse(_ response: HTTPURLResponse, with data: Data, from request: URLRequest,
                                     completion: @escaping Callback) {
        let response = Response(request: request, response: response, data: data)
        switch response.statusCode {
        case 200 ..< 300:
            completion(.success(response))
        default:
            completion(.failure(Error.invalidResponse(response)))
        }
    }
    
    private func handleErrorResponse(_ error: Swift.Error, from request: URLRequest,
                                     completion: @escaping Callback) {
        let nsError = error as NSError
        if nsError.domain == NSURLErrorDomain && nsError.code == NSURLErrorNetworkConnectionLost {
            // Retry request because of the iOS bug - SEE: https://github.com/AFNetworking/AFNetworking/issues/2314
            resumeDataTask(with: request, completion: completion)
        } else {
            completion(.failure(error))
        }
    }
    
}

// MARK: - Extensions

public extension Fetcher {
    public static func apiResponseResult(from result: ResponseResult) -> APIResponseResult {
        switch result {
        case .success(let response): return .success(response)
        case .failure(let error): return .failure(error)
        }
    }
}

extension Fetcher.Response: Equatable {
    public static func ==(lhs: Fetcher.Response, rhs: Fetcher.Response) -> Bool {
        return lhs.request == rhs.request && lhs.response == rhs.response && lhs.data == rhs.data
    }
}

extension Fetcher.Error: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidResponse(let response):
            let code = response.statusCode
            let status = HTTPURLResponse.localizedString(forStatusCode: code).capitalized
            let text = "Request failed with status code: \(code) \(status)"
            return text
        }
    }
}

extension Fetcher.Error: CustomNSError {
    public static var errorDomain: String {
        return "net.tadija.AENetwork/Fetcher.Error"
    }
    public var errorCode: Int {
        switch self {
        case .invalidResponse(let response):
            return response.statusCode
        }
    }
    public var errorUserInfo: [String : Any] {
        switch self {
        case .invalidResponse(let response):
            return ["response" : response]
        }
    }
}
