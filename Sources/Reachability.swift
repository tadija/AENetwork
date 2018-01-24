/**
 *  https://github.com/tadija/AENetwork
 *  Copyright (c) Marko Tadić 2017-2018
 *  Created by Mihailo Rančić
 *  Licensed under the MIT license. See LICENSE file.
 */

import Foundation
import SystemConfiguration

extension Notification.Name {
    public static let reachabilityConnectionDidChange = Notification.Name("Reachability.Connection.Did.Change")
}

private func callback(networkReference: SCNetworkReachability,
                      flags: SCNetworkReachabilityFlags, info: UnsafeMutableRawPointer?) {
    guard let info = info else { return }
    let reachability = Unmanaged<Reachability>.fromOpaque(info).takeUnretainedValue()
    reachability.callListenersIfNeeded()
}

open class Reachability {
    
    // MARK: Types
    
    public enum Connection: String {
        case unknown
        case none
        case wifi
        case cellular
    }

    // MARK: Singleton

    public static let shared = Reachability()

    // MARK: Properties

    public var flags: SCNetworkReachabilityFlags {
        var flags = SCNetworkReachabilityFlags()
        guard let ref = networkReference, SCNetworkReachabilityGetFlags(ref, &flags) else {
            return SCNetworkReachabilityFlags()
        }
        return flags
    }
    
    public var connection: Connection {
        guard networkReference != nil else { return .unknown }

        guard flags.contains(.reachable) else { return .none }
        
        var connection: Connection = .none
        
        if !flags.contains(.connectionRequired) {
            connection = .wifi
        }
        if flags.contains(.connectionOnTraffic) || flags.contains(.connectionOnDemand) {
            if !flags.contains(.interventionRequired) {
                connection = .wifi
            }
        }
        #if os(iOS)
            if flags.contains(.isWWAN) {
                connection = .cellular
            }
        #endif
        
        return connection
    }

    public var isConnectedToNetwork: Bool {
        return connection == .wifi || connection == .cellular
    }

    public var connectionDidChange: ((Reachability) -> ())?

    // MARK: Private Properties

    private let networkReference: SCNetworkReachability?
    private let queue = DispatchQueue(label: "net.tadija.AENetwork.Reachability")
    private var previousFlags: SCNetworkReachabilityFlags?
    private var isNotifierRunning = false
    
    // MARK: Init

    public init(hostname: String) {
        self.networkReference = SCNetworkReachabilityCreateWithName(nil, hostname)
    }

    public init() {
        var zeroAddress = sockaddr()
        zeroAddress.sa_len = UInt8(MemoryLayout<sockaddr>.size)
        zeroAddress.sa_family = sa_family_t(AF_INET)
        self.networkReference = SCNetworkReachabilityCreateWithAddress(nil, &zeroAddress)
    }
    
    deinit {
        stopNotifier()
    }
    
    // MARK: API
    
    public func startNotifier() {
        guard !isNotifierRunning, let ref = networkReference else { return }
        
        var context = SCNetworkReachabilityContext(version: 0, info: nil, retain: nil, release: nil, copyDescription: nil)
        context.info = UnsafeMutableRawPointer(Unmanaged<Reachability>.passUnretained(self).toOpaque())
        
        SCNetworkReachabilitySetCallback(ref, callback, &context)
        SCNetworkReachabilitySetDispatchQueue(ref, queue)
        
        queue.async { [weak self] in
            self?.callListenersIfNeeded()
        }
        
        isNotifierRunning = true
    }
    
    public func stopNotifier() {
        guard let ref = networkReference else { return }
        
        SCNetworkReachabilitySetCallback(ref, nil, nil)
        SCNetworkReachabilitySetDispatchQueue(ref, nil)

        isNotifierRunning = false
    }
    
    // MARK: Helpers
    
    fileprivate func callListenersIfNeeded() {
        guard previousFlags != flags else { return }
        previousFlags = flags
        
        DispatchQueue.main.async { [weak self] in
            if let strongSelf = self {
                strongSelf.connectionDidChange?(strongSelf)
                NotificationCenter.default.post(name: .reachabilityConnectionDidChange, object: strongSelf)
            }
        }
    }
    
}
