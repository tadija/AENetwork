/**
 *  https://github.com/tadija/AENetwork
 *  Copyright © 2017-2020 Marko Tadić
 *  Licensed under the MIT license
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
    static var isOnline: Bool {
        return shared.reachability.state.isOnline
    }
    static var isOffline: Bool {
        return !isOnline
    }
}

public extension URLRequest {
    func send(over network: Network = .shared, completion: @escaping Fetcher.Callback) {
        network.fetcher.send(self, completion: completion)
    }
}
