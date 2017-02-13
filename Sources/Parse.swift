import Foundation

extension Network {
    
    func parseJSONDictionary(with data: Data) throws -> [String : Any] {
        return try parseJSON(data: data)
    }
    
    func parseJSONArray(with data: Data) throws -> [Any] {
        return try parseJSON(data: data)
    }
    
    private func parseJSON<T>(data: Data) throws -> T {
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            if let json = json as? T {
                return json
            } else {
                throw NetworkError.parsingFailed
            }
        } catch {
            throw error
        }
    }
    
}
