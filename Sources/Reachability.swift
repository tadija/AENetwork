/**
 *  https://github.com/tadija/AENetwork
 *  Copyright (c) Mihailo Rančić 2018
 *  Licensed under the MIT license. See LICENSE file.
 */

import Foundation
import SystemConfiguration

extension Notification.Name {
    public static let reachabilityStatusDidChange = Notification.Name("Reachability.Status.Did.Change")
}

public class Reachability {
    
    // MARK: Types
    
    public enum Status {
        case notReachable
        case reachableOnEthernetOrWiFi
        case reachableOnCellular
    }
    
    // MARK: Public Properties
    
    public var statusDidChange: ((Status) -> ())?
    
    public var status: Status {
        guard flags.contains(.reachable) else { return .notReachable }
        
        var status: Status = .notReachable
        
        if !flags.contains(.connectionRequired) {
            status = .reachableOnEthernetOrWiFi
        }
        if flags.contains(.connectionOnTraffic) || flags.contains(.connectionOnDemand) {
            if !flags.contains(.interventionRequired) {
                status = .reachableOnEthernetOrWiFi
            }
        }
        if flags.contains(.isWWAN) {
            status = .reachableOnCellular
        }
        
        return status
    }
    
    public var isReachable: Bool {
        return status != .notReachable
    }
    
    // MARK: Private Properties
    
    private let reachabilityRef: SCNetworkReachability! = {
        var zeroAddress = sockaddr()
        zeroAddress.sa_len = UInt8(MemoryLayout<sockaddr>.size)
        zeroAddress.sa_family = sa_family_t(AF_INET)
        
        return SCNetworkReachabilityCreateWithAddress(nil, &zeroAddress)
    }()
    
    private let reachabilityCallBack: SCNetworkReachabilityCallBack? = { (_,_,info) in
        guard let info = info else { return }
        
        let reachability = Unmanaged<Reachability>.fromOpaque(info).takeUnretainedValue()
        reachability.networkListener()
    }
    
    private var flags: SCNetworkReachabilityFlags {
        var flags = SCNetworkReachabilityFlags()
        SCNetworkReachabilityGetFlags(reachabilityRef, &flags)
        return flags
    }
    
    private var previousFlags: SCNetworkReachabilityFlags?
    private var isNotifierRunning = false
    private let queue = DispatchQueue(label: "net.tadija.AENetwork.Reachability")
    
    // MARK: Lifecycle
    
    deinit {
        stopNotifier()
    }
    
    // MARK: Notifier API
    
    public func startNotifier() {
        guard !isNotifierRunning else { return }
        
        var context = SCNetworkReachabilityContext(version: 0, info: nil, retain: nil, release: nil, copyDescription: nil)
        context.info = Unmanaged.passUnretained(self).toOpaque()
        
        SCNetworkReachabilitySetCallback(reachabilityRef, reachabilityCallBack, &context)
        SCNetworkReachabilitySetDispatchQueue(reachabilityRef, queue)
        
        queue.async { [weak self] in
            self?.networkListener()
        }
        
        isNotifierRunning = true
    }
    
    public func stopNotifier() {
        defer {
            isNotifierRunning = false
        }
        
        SCNetworkReachabilitySetCallback(reachabilityRef, nil, nil)
        SCNetworkReachabilitySetDispatchQueue(reachabilityRef, nil)
    }
    
    // MARK: Listener
    
    private func networkListener() {
        guard previousFlags != flags else { return }
        previousFlags = flags
        
        DispatchQueue.main.async { [weak self] in
            if let strongSelf = self {
                strongSelf.statusDidChange?(strongSelf.status)
                NotificationCenter.default.post(name: .reachabilityStatusDidChange, object: strongSelf.status)
            }
        }
    }
    
}
