/**
 *  https://github.com/tadija/AENetwork
 *  Copyright (c) Mihailo Rančić 2018
 *  Licensed under the MIT license. See LICENSE file.
 */

import XCTest
@testable import AENetwork

class ReachabilityTests: XCTestCase {
    
    // MARK: Properties
    
    let reachability = Reachability()
    
    // MARK: Lifecycle
    
    override func setUp() {
        super.setUp()
        
        reachability.startNotifier()
    }
    
    override func tearDown() {
        reachability.stopNotifier()
        
        super.tearDown()
    }
    
    // MARK: Tests
    
    func testThatBlockIsExecutedWhenNotiferStarts() {
        let closureExpectation = expectation(description: "listener closure should be executed")
        reachability.statusDidChange = { (status) in
            closureExpectation.fulfill()
        }
        waitForExpectations(timeout: 3, handler: nil)
    }
    
    func testThatNotificationIsPostedWhenNotifierStarts() {
        expectation(forNotification: .reachabilityStatusDidChange, object: nil) { (notification) in
            XCTAssertNotNil(notification.object as? Reachability.Status, "Should set status from notification.")
            return true
        }
        waitForExpectations(timeout: 3, handler: nil)
    }
    
    static var allTests : [(String, (ReachabilityTests) -> () throws -> Void)] {
        return [
            ("testThatBlockIsExecutedWhenNotiferStarts", testThatBlockIsExecutedWhenNotiferStarts),
            ("testThatNotificationIsPostedWhenNotifierStarts", testThatNotificationIsPostedWhenNotifierStarts)
        ]
    }
    
}
