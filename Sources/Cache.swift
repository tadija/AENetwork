import Foundation

extension Network {
    
    func cacheResponse(_ response: HTTPURLResponse, with data: Data, from request: URLRequest) {
        let cache = CachedURLResponse(response: response, data: data, storagePolicy: .allowed)
        URLCache.shared.storeCachedResponse(cache, for: request)
    }
    
    func getCachedResponse(for request: URLRequest) -> CachedURLResponse? {
        guard
            let cache = URLCache.shared.cachedResponse(for: request),
            let delegate = cacheDelegate
        else { return nil }
        
        if delegate.isValidCache(cache) {
            return cache
        } else {
            URLCache.shared.removeCachedResponse(for: request)
            return nil
        }
    }
    
}
