import Foundation

public typealias ThrowDataInClosure = (() throws -> Data) -> Void
public typealias ThrowDictionaryInClosure = (() throws -> [String : Any]) -> Void
public typealias ThrowArrayInClosure = (() throws -> [Any]) -> Void

extension Network {
    
    // MARK: - API
    
    public func fetchData(with request: URLRequest, completion: @escaping ThrowDataInClosure) {
        if let cachedResponse = getCachedResponse(for: request) {
            completion {
                return cachedResponse.data
            }
        } else {
            sendRequest(request, completion: completion)
        }
    }
    
    public func fetchDictionary(with request: URLRequest, completion: @escaping ThrowDictionaryInClosure) {
        fetchData(with: request) { (closure) -> Void in
            do {
                let data = try closure()
                let dictionary = try self.parseJSONDictionary(with: data)
                completion {
                    return dictionary
                }
            } catch {
                completion {
                    throw error
                }
            }
        }
    }
    
    public func fetchArray(with request: URLRequest, completion: @escaping ThrowArrayInClosure) {
        fetchData(with: request) { (closure) -> Void in
            do {
                let data = try closure()
                let array = try self.parseJSONArray(with: data)
                completion {
                    return array
                }
            } catch {
                completion {
                    throw error
                }
            }
        }
    }
    
}
