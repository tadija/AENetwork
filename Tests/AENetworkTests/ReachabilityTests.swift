/**
 *  https://github.com/tadija/AENetwork
 *  Copyright (c) Marko Tadić 2017-2018
 *  Created by Mihailo Rančić
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
        let closureExpectation = expectation(description: "`connectionDidChange` should be executed.")
        reachability.connectionDidChange = { _ in
            closureExpectation.fulfill()
        }
        waitForExpectations(timeout: 3, handler: nil)
    }
    
    func testThatNotificationIsPostedWhenNotifierStarts() {
        expectation(forNotification: .reachabilityConnectionDidChange, object: nil) { (notification) in
            XCTAssertNotNil(notification.object as? Reachability,
                            ".reachabilityConnectionDidChange notification should be posted.")
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
