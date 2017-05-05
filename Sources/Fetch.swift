import Foundation

extension Network {
    
    // MARK: - API
    
    public func fetchData(with request: URLRequest, completion: @escaping Completion.ThrowData) {
        if let cachedResponse = getCachedResponse(for: request) {
            completion {
                return cachedResponse.data
            }
        } else {
            sendRequest(request, completion: completion)
        }
    }
    
    public func fetchDictionary(with request: URLRequest, completion: @escaping Completion.ThrowDictionary) {
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
    
    public func fetchArray(with request: URLRequest, completion: @escaping Completion.ThrowArray) {
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
