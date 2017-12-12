//
//  URLRequest+Helpers.swift
//  AENetwork
//
//  Created by Marko Tadić on 12/12/17.
//

import Foundation

extension URLRequest {

    // MARK: API

    public func fetchData(with network: Network = .shared, completion: @escaping Completion.ThrowableData) {
        network.fetchData(with: self, completion: completion)
    }

    public func fetchDictionary(with network: Network = .shared, completion: @escaping Completion.ThrowableDictionary) {
        network.fetchDictionary(with: self, completion: completion)
    }

    public func fetchArray(with network: Network = .shared, completion: @escaping Completion.ThrowableArray) {
        network.fetchArray(with: self, completion: completion)
    }

}
