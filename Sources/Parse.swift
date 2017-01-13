//
// Parse.swift
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
    
    internal func parseDictionary(from data: Data) throws -> [AnyHashable : Any] {
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            if let dictionary = json as? [AnyHashable : Any] {
                return dictionary
            } else {
                throw NetworkError.parsingFailed
            }
        } catch {
            throw error
        }
    }
    
    internal func parseArray(from data: Data) throws -> [Any] {
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            if let array = json as? [Any] {
                return array
            } else {
                throw NetworkError.parsingFailed
            }
        } catch {
            throw error
        }
    }
    
}
