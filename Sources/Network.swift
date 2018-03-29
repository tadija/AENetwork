/**
 *  https://github.com/tadija/AENetwork
 *  Copyright (c) Marko Tadić 2017-2018
 *  Licensed under the MIT license. See LICENSE file.
 */

import Foundation

// MARK: - Network

open class Network {

    // MARK: Singleton
    
    public static let shared = Network()
    
    // MARK: Properties
    
    public let reachability: Reachability
    public let fetcher: Fetcher
    
    // MARK: Init
    
    public init(reachability: Reachability = Reachability(),
                fetcher: Fetcher = Fetcher()) {
        self.reachability = reachability
        self.fetcher = fetcher
    }
    
}

// MARK: - Facade

public extension Network {
    public static var isOnline: Bool {
        return shared.reachability.state.isOnline
    }
    public static var isOffline: Bool {
        return !isOnline
    }
}

public extension URLRequest {
    public func send(over network: Network = .shared, completion: @escaping Fetcher.Callback) {
        network.fetcher.send(self, completion: completion)
    }
}
