/**
 *  https://github.com/tadija/AENetwork
 *  Copyright (c) Marko Tadić 2017-2018
 *  Licensed under the MIT license. See LICENSE file.
 */

import XCTest
@testable import AENetwork

class NetworkTests: XCTestCase {

    // MARK: Tests

    static var allTests : [(String, (NetworkTests) -> () throws -> Void)] {
        return [

        ]
    }

}

@available(iOS 10.0, macOS 10.12, *)
class NetworkQueueTests: XCTestCase {

    // MARK: Properties

    let network = Network.shared

    // MARK: Tests

    func testCompletionInBackgroundQueue() {
        let request = URLRequest.get(url: "https://httpbin.org/get")

        let queueExpectation = expectation(description: "Background")
        network.sendRequest(request, completionQueue: .global()) { (result) in
            dispatchPrecondition(condition: .notOnQueue(.main))
            queueExpectation.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
    }

    func testCompletionInMainQueue() {
        let request = URLRequest.get(url: "https://httpbin.org/get")

        let queueExpectation = expectation(description: "Main")
        network.sendRequest(request, completionQueue: .main) { (result) in
            dispatchPrecondition(condition: .onQueue(.main))
            queueExpectation.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
    }

    static var allTests : [(String, (NetworkQueueTests) -> () throws -> Void)] {
        return [
            ("testCompletionInBackgroundQueue", testCompletionInBackgroundQueue),
            ("testCompletionInMainQueue", testCompletionInMainQueue)
        ]
    }

}
