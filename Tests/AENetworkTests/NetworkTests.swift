/**
 *  https://github.com/tadija/AENetwork
 *  Copyright (c) Marko Tadić 2017-2018
 *  Licensed under the MIT license. See LICENSE file.
 */

import XCTest
@testable import AENetwork

class NetworkTests: XCTestCase {

    static var allTests : [(String, (NetworkTests) -> () throws -> Void)] {
        return [
            ("testFacadeForReachability", testFacadeForReachability),
            ("testFacadeForFetchingRequest", testFacadeForFetchingRequest)
        ]
    }
    
    // MARK: Properties
    
    let network = Network()

    // MARK: Tests
    
    func testFacadeForReachability() {
        XCTAssertEqual(Network.isOnline, network.reachability.state.isOnline, "Should be equal.")
        XCTAssertEqual(Network.isOffline, !network.reachability.state.isOnline, "Should be opposite.")
    }
    
    func testFacadeForFetchingRequest() {
        let requestExpectation = expectation(description: "Request")
        let request = URLRequest(url: "https://httpbin.org/get")
        request.send { (result) in
            XCTAssertNotNil(try? result.get(), "Should have value in result.")
            requestExpectation.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
    }

}
