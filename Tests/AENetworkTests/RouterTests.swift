/**
 *  https://github.com/tadija/AENetwork
 *  Copyright (c) Marko Tadić 2017
 *  Licensed under the MIT license. See LICENSE file.
 */

import XCTest
@testable import AENetwork

class RouterTests: XCTestCase {

    // MARK: Properties

    let network = Network()
    let request = URLRequest(url: URL(string: "https://httpbin.org/get")!)

    // MARK: Setup

    override func setUp() {
        network.isCacheEnabled = true
    }

    // MARK: Tests

    func testFetchDictionary() {
        let fetchDictionary = expectation(description: "Fetch Dictionary")

        network.router.fetchDictionary(with: request) { (closure) in
            do {
                let _ = try closure()
                XCTAssert(true, "Should be able to parse dictionary from: \(String(describing: self.request.url))")
            } catch {
                XCTAssert(false, "Should be able to fetch dictionary without error: \(error.localizedDescription)")
            }
            fetchDictionary.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }

    func testFetchDictionaryError() {
        let fetchDictionary = expectation(description: "Fetch Dictionary With Error")
        
        let request = URLRequest(url: URL(string: "https://httpbin.org")!)
        network.router.fetchDictionary(with: request) { (closure) in
            do {
                let _ = try closure()
                XCTAssert(false, "Should not be able to parse dictionary from: \(String(describing: request.url))")
            } catch {
                XCTAssert(true, "Should throw error from: \(String(describing: request.url))")
            }
            fetchDictionary.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }

    func testFetchArray() {
        /// - TODO: find some url which returns array
    }

    func testFetchArrayError() {
        let fetchArray = expectation(description: "Fetch Array With Error")

        network.router.fetchArray(with: request) { (closure) in
            do {
                let _ = try closure()
                XCTAssert(false, "Should not be able to parse array from: \(String(describing: self.request.url))")
            } catch {
                XCTAssert(true, "Should throw error: \(error.localizedDescription)")
            }
            fetchArray.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }

    func testFetchError() {
        let fetchDictionary = expectation(description: "Fetch Error")

        let request = URLRequest(url: URL(string: "https://test.test")!)
        network.router.fetchDictionary(with: request) { (closure) in
            do {
                let _ = try closure()
                XCTAssert(false, "Should not be able to parse dictionary from: \(String(describing: request.url))")
            } catch {
                XCTAssert(true, "Should throw error: \(error.localizedDescription)")
            }
            fetchDictionary.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }

    static var allTests : [(String, (RouterTests) -> () throws -> Void)] {
        return [
            ("testFetchDictionary", testFetchDictionary),
            ("testFetchDictionaryError", testFetchDictionaryError),
            ("testFetchArray", testFetchArray),
            ("testFetchArrayError", testFetchArrayError),
            ("testFetchError", testFetchError),
        ]
    }

}
