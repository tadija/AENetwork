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
            ("testFetchDictionary", testFetchDictionary),
            ("testFetchDictionaryError", testFetchDictionaryError),
            ("testFetchArray", testFetchArray),
            ("testFetchArrayError", testFetchArrayError),
            ("testFetchError", testFetchError),
            ("testResponseError", testResponseError),
        ]
    }

    // MARK: Properties

    let network = Network.shared

    // MARK: Tests

    func testFetchDictionary() {
        fetchDictionary(from: "https://httpbin.org/get")
    }

    func testFetchDictionaryError() {
        fetchDictionary(from: "https://httpbin.org", shouldFail: true)
    }

    func testFetchArray() {
        fetchArray(from: "http://www.mocky.io/v2/5a304e1f2d0000c239a83dc5")
    }

    func testFetchArrayError() {
        fetchArray(from: "https://httpbin.org/get", shouldFail: true)
    }

    func testFetchError() {
        fetchDictionary(from: "https://test.test", shouldFail: true)
    }

    func testResponseError() {
        fetchDictionary(from: "https://httpbin.org/test", shouldFail: true)
    }

    // MARK: Helpers

    private func fetchDictionary(from url: URL, shouldFail: Bool = false) {
        let requestExpectation = expectation(description: "Request")

        let request = URLRequest(url: url)
        network.fetchRequest(request) { (result) in
            do {
                let result = try result()
                let _ = try result.toDictionary()
                XCTAssertEqual(result.response.statusCode, 200, "Should have response code 200.")
                XCTAssertNotNil(result.dictionary, "Should not be nil.")
                XCTAssert(!shouldFail, "Should be able to parse dictionary from: \(String(describing: request.url))")
            } catch {
                XCTAssert(shouldFail, "Should throw error from: \(String(describing: request.url))")
            }
            requestExpectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }

    private func fetchArray(from url: URL, shouldFail: Bool = false) {
        let requestExpectation = expectation(description: "Request")

        let request = URLRequest(url: url)
        network.fetchRequest(request) { (result) in
            do {
                let result = try result()
                let _ = try result.toArray()
                XCTAssertEqual(result.response.statusCode, 200, "Should have response code 200.")
                XCTAssertNotNil(result.array, "Should not be nil.")
                XCTAssert(!shouldFail, "Should be able to parse array from: \(String(describing: request.url))")
            } catch {
                XCTAssert(shouldFail, "Should throw error from: \(String(describing: request.url))")
            }
            requestExpectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }

}

@available(iOS 10.0, macOS 10.12, *)
class NetworkQueueTests: XCTestCase {

    static var allTests : [(String, (NetworkQueueTests) -> () throws -> Void)] {
        return [
            ("testCompletionInBackgroundQueue", testCompletionInBackgroundQueue),
            ("testCompletionInMainQueue", testCompletionInMainQueue)
        ]
    }

    // MARK: Properties

    let network = Network.shared

    // MARK: Tests

    func testCompletionInBackgroundQueue() {
        let request = URLRequest.get(url: "https://httpbin.org/get")

        let queueExpectation = expectation(description: "Background")
        network.fetchRequest(request, completionQueue: .global()) { (result) in
            dispatchPrecondition(condition: .notOnQueue(.main))
            queueExpectation.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
    }

    func testCompletionInMainQueue() {
        let request = URLRequest.get(url: "https://httpbin.org/get")

        let queueExpectation = expectation(description: "Main")
        network.fetchRequest(request, completionQueue: .main) { (result) in
            dispatchPrecondition(condition: .onQueue(.main))
            queueExpectation.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
    }

}
