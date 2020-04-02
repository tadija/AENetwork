/**
 *  https://github.com/tadija/AENetwork
 *  Copyright © 2017-2020 Marko Tadić
 *  Created by Mihailo Rančić
 *  Licensed under the MIT license
 */

import Foundation
import SystemConfiguration

open class Reachability {

    // MARK: Types

    public enum State: String {
        case offline
        case cellular
        case wifi

        public var isOnline: Bool {
            self != .offline
        }
    }

    // MARK: Properties

    public var flags: SCNetworkReachabilityFlags {
        var flags = SCNetworkReachabilityFlags()
        guard let ref = networkReference, SCNetworkReachabilityGetFlags(ref, &flags) else {
            return SCNetworkReachabilityFlags()
        }
        return flags
    }

    public var state: State {
        guard networkReference != nil else { return .offline }
        guard flags.contains(.reachable) else { return .offline }

        var state: State = .offline

        if !flags.contains(.connectionRequired) {
            state = .wifi
        }
        if flags.contains(.connectionOnTraffic) || flags.contains(.connectionOnDemand) {
            if !flags.contains(.interventionRequired) {
                state = .wifi
            }
        }
        #if os(iOS)
        if flags.contains(.isWWAN) {
            state = .cellular
        }
        #endif

        return state
    }

    public var stateDidChange: ((State) -> Void)?

    private let networkReference: SCNetworkReachability?
    private let queue = DispatchQueue(label: "AENetwork.Reachability.Queue")
    private var previousFlags: SCNetworkReachabilityFlags?
    private var isNotifierRunning = false

    // MARK: Init

    public init(hostname: String? = nil) {
        if let hostname = hostname {
            networkReference = SCNetworkReachabilityCreateWithName(nil, hostname)
        } else {
            var zeroAddress = sockaddr()
            zeroAddress.sa_len = UInt8(MemoryLayout<sockaddr>.size)
            zeroAddress.sa_family = sa_family_t(AF_INET)
            networkReference = SCNetworkReachabilityCreateWithAddress(nil, &zeroAddress)
        }
    }

    deinit {
        stopMonitoring()
    }

    // MARK: API

    public func startMonitoring() {
        guard !isNotifierRunning, let ref = networkReference else { return }

        var context = SCNetworkReachabilityContext(
            version: 0, info: nil, retain: nil, release: nil, copyDescription: nil
        )
        context.info = UnsafeMutableRawPointer(
            Unmanaged<Reachability>.passUnretained(self).toOpaque()
        )

        SCNetworkReachabilitySetCallback(ref, callback, &context)
        SCNetworkReachabilitySetDispatchQueue(ref, queue)

        queue.async { [weak self] in
            self?.callListenersIfNeeded()
        }

        isNotifierRunning = true
    }

    public func stopMonitoring() {
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
                strongSelf.stateDidChange?(strongSelf.state)
            }
        }
    }

}

private func callback(networkReference: SCNetworkReachability,
                      flags: SCNetworkReachabilityFlags, info: UnsafeMutableRawPointer?) {
    guard let info = info else { return }
    let reachability = Unmanaged<Reachability>.fromOpaque(info).takeUnretainedValue()
    reachability.callListenersIfNeeded()
}
