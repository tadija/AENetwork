/**
 *  https://github.com/tadija/AENetwork
 *  Copyright (c) Marko Tadić 2017
 *  Licensed under the MIT license. See LICENSE file.
 */

import XCTest
@testable import AENetwork

class FetcherTests: XCTestCase {

    // MARK: Properties

    let network = Network()

    // MARK: Setup

    override func setUp() {
        network.isCacheEnabled = true
    }

    // MARK: Tests

    func testFetchDictionary() {
        let url = URL(string: "https://httpbin.org/get")!
        performDictionaryRequest(with: url)
    }

    func testFetchDictionaryError() {
        let url = URL(string: "https://httpbin.org")!
        performDictionaryRequest(with: url, shouldFail: true)
    }

    func testFetchArray() {
        let url = URL(string: "https://jsonplaceholder.typicode.com/posts")!
        performArrayRequest(with: url)
    }

    func testFetchArrayError() {
        let url = URL(string: "https://httpbin.org/get")!
        performArrayRequest(with: url, shouldFail: true)
    }

    func testFetchError() {
        let url = URL(string: "https://test.test")!
        performDictionaryRequest(with: url, shouldFail: true)
    }

    func testResponseError() {
        let url = URL(string: "https://httpbin.org/test")!
        performDictionaryRequest(with: url, shouldFail: true)
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

    private func performDictionaryRequest(with url: URL, shouldFail: Bool = false) {
        let requestExpectation = expectation(description: "Request")

        let request = URLRequest(url: url)
        network.fetcher.dictionary(with: request) { (closure) in
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

    private func performArrayRequest(with url: URL, shouldFail: Bool = false) {
        let requestExpectation = expectation(description: "Request")

        let request = URLRequest(url: url)
        network.fetcher.array(with: request) { (closure) in
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
