import Foundation

public protocol NetworkCacheDelegate: class {
    func shouldCacheResponse(from request: URLRequest) -> Bool
    func isValidCache(_ cache: CachedURLResponse) -> Bool
}

public class Network {
    
    // MARK: - Types
    
    public struct Completion {
        public typealias ThrowData = (() throws -> Data) -> Void
        public typealias ThrowDictionary = (() throws -> [String : Any]) -> Void
        public typealias ThrowArray = (() throws -> [Any]) -> Void
    }
    
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
    
    func sendRequest(_ request: URLRequest, completion: @escaping Completion.ThrowData) {
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let response = response as? HTTPURLResponse, let data = data, error == nil {
                self.handleResponse(response, with: data, from: request, completion: completion)
            } else {
                self.handleResponseError(error, from: request, completion: completion)
            }
        }.resume()
    }
    
    private func handleResponse(_ response: HTTPURLResponse,
                                with data: Data,
                                from request: URLRequest,
                                completion: Completion.ThrowData) {
        switch response.statusCode {
        case 200 ..< 300:
            if let delegate = cacheDelegate, delegate.shouldCacheResponse(from: request) {
                cacheResponse(response, with: data, from: request)
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
                                     completion: @escaping Completion.ThrowData) {
        if let error = error as NSError? {
            if error.domain == NSURLErrorDomain && error.code == NSURLErrorNetworkConnectionLost {
                // Retry request because of the iOS bug - SEE: https://github.com/AFNetworking/AFNetworking/issues/2314
                fetchData(with: request, completion: completion)
            } else {
                completion {
                    throw error
                }
            }
        } else {
            completion {
                throw NetworkError.badResponse
            }
        }
    }
    
}
