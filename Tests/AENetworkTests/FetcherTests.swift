/**
 *  https://github.com/tadija/AENetwork
 *  Copyright (c) Marko Tadić 2017-2018
 *  Licensed under the MIT license. See LICENSE file.
 */

import XCTest
@testable import AENetwork

/// - TODO: Refactor later
class FetcherTests: XCTestCase {

    // MARK: Properties

    let network = Network.shared

    // MARK: Tests

    func testFetchDictionary() {
        sendDictionaryRequest(withURL: "https://httpbin.org/get")
    }

    func testFetchDictionaryError() {
        sendDictionaryRequest(withURL: "https://httpbin.org", shouldFail: true)
    }

    func testFetchArray() {
        sendArrayRequest(withURL: "http://www.mocky.io/v2/5a304e1f2d0000c239a83dc5")
    }

    func testFetchArrayError() {
        sendArrayRequest(withURL: "https://httpbin.org/get", shouldFail: true)
    }

    func testFetchError() {
        sendDictionaryRequest(withURL: "https://test.test", shouldFail: true)
    }

    func testResponseError() {
        sendDictionaryRequest(withURL: "https://httpbin.org/test", shouldFail: true)
    }

    static var allTests : [(String, (FetcherTests) -> () throws -> Void)] {
        return [
            ("testFetchDictionary", testFetchDictionary),
            ("testFetchDictionaryError", testFetchDictionaryError),
            ("testFetchArray", testFetchArray),
            ("testFetchArrayError", testFetchArrayError),
            ("testFetchError", testFetchError),
            ("testResponseError", testResponseError),
        ]
    }

    // MARK: Helpers

    private func sendDictionaryRequest(withURL url: URL, shouldFail: Bool = false) {
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

    private func sendArrayRequest(withURL url: URL, shouldFail: Bool = false) {
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
