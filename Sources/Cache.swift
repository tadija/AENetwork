//
// Cache.swift
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
