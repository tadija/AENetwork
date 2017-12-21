/**
 *  https://github.com/tadija/AENetwork
 *  Copyright (c) Marko Tadić 2017
 *  Licensed under the MIT license. See LICENSE file.
 */

import XCTest
@testable import AENetwork

class FetcherTests: XCTestCase {

    // MARK: Properties

    let fetcher = Fetcher.shared

    // MARK: Tests

    func testFetchDictionary() {
        performDictionaryRequest(withURL: "https://httpbin.org/get")
    }

    func testFetchDictionaryError() {
        performDictionaryRequest(withURL: "https://httpbin.org", shouldFail: true)
    }

    func testFetchArray() {
        performArrayRequest(withURL: "http://www.mocky.io/v2/5a304e1f2d0000c239a83dc5")
    }

    func testFetchArrayError() {
        performArrayRequest(withURL: "https://httpbin.org/get", shouldFail: true)
    }

    func testFetchError() {
        performDictionaryRequest(withURL: "https://test.test", shouldFail: true)
    }

    func testResponseError() {
        performDictionaryRequest(withURL: "https://httpbin.org/test", shouldFail: true)
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

    private func performDictionaryRequest(withURL url: URL, shouldFail: Bool = false) {
        let requestExpectation = expectation(description: "Request")

        let request = URLRequest(url: url)
        fetcher.dictionary(with: request) { (closure) in
            do {
                let _ = try closure()
                XCTAssert(!shouldFail, "Should be able to parse dictionary from: \(String(describing: request.url))")
            } catch {
                XCTAssert(shouldFail, "Should throw error from: \(String(describing: request.url))")
            }
            requestExpectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }

    private func performArrayRequest(withURL url: URL, shouldFail: Bool = false) {
        let requestExpectation = expectation(description: "Request")

        let request = URLRequest(url: url)
        fetcher.array(with: request) { (closure) in
            do {
                let _ = try closure()
                XCTAssert(!shouldFail, "Should be able to parse array from: \(String(describing: request.url))")
            } catch {
                XCTAssert(shouldFail, "Should throw error from: \(String(describing: request.url))")
            }
            requestExpectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }

}
