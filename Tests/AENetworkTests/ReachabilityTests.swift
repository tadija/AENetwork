/**
 *  https://github.com/tadija/AENetwork
 *  Copyright (c) Marko Tadić 2017-2019
 *  Created by Mihailo Rančić
 *  Licensed under the MIT license. See LICENSE file.
 */

import XCTest
@testable import AENetwork

class ReachabilityTests: XCTestCase {

    static var allTests : [(String, (ReachabilityTests) -> () throws -> Void)] {
        return [
            ("testStateDidChangeIsCalled", testStateDidChangeIsCalled),
            ("testReachabilityFlags", testReachabilityFlags)
        ]
    }
    
    // MARK: Tests
    
    func testStateDidChangeIsCalled() {
        let closureExpectation = expectation(description: "`stateDidChange` should be called.")
        let reachability = Reachability()
        reachability.stateDidChange = { (state) in
            XCTAssertTrue(state.isOnline == (state == .cellular || state == .wifi), "State is wrong.")
            closureExpectation.fulfill()
        }
        reachability.startMonitoring()
        waitForExpectations(timeout: 3, handler: nil)
    }
    
    func testReachabilityFlags() {
        let reachability = Reachability(hostname: "https://httpbin.org")
        XCTAssertEqual(reachability.state.isOnline, reachability.flags.contains(.reachable), "State is wrong.")
    }
    
}
