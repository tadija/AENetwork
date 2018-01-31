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
        request.fetch { (result) in
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
        request.fetch { (result) in
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

class NetworkFetchDelegateTests: XCTestCase, NetworkFetchDelegate {

    static var allTests : [(String, (NetworkFetchDelegateTests) -> () throws -> Void)] {
        return [
            ("testWillSkipRequest", testWillSkipRequest),
            ("testWillSendRequest", testWillSendRequest),
            ("testWillReceiveResult", testWillReceiveResult),
            ("testInterceptRequest", testInterceptRequest),
            ("testInterceptResult", testInterceptResult),
            ("testDefaultNetworkFetchDelegate", testDefaultNetworkFetchDelegate),
        ]
    }

    // MARK: Types

    class DefaultNetworkFetchDelegate: NetworkFetchDelegate {}

    // MARK: Properties

    let network = Network()

    let networkForTestingDefaultFetchDelegate = Network()
    let defaultFetchDelegate = DefaultNetworkFetchDelegate()

    // MARK: Lifecycle

    override func setUp() {
        network.fetchDelegate = self
        networkForTestingDefaultFetchDelegate.fetchDelegate = defaultFetchDelegate
    }

    // MARK: Tests

    private let requestForTestingWillSkip = URLRequest.post(url: "https://httpbin.org/post")
    private var willSkipRequestExpectation: XCTestExpectation?
    private var skippedRequest: URLRequest?

    private let requestForTestingWillSend = URLRequest.get(url: "https://httpbin.org/get")
    private var willSendRequestExpectation: XCTestExpectation?
    private var sentRequest: URLRequest?

    private let requestForTestingWillReceiveResult = URLRequest.put(url: "https://httpbin.org/put")
    private var willReceiveResultExpectation: XCTestExpectation?
    private var receivedResult: Network.FetchResult?

    private let requestForTestingInterceptRequest = URLRequest.post(url: "https://httpbin.org/get")
    private var interceptRequestExpectation: XCTestExpectation?
    private var interceptedRequest: URLRequest?

    private let requestForTestingInterceptResult = URLRequest.delete(url: "https://httpbin.org/delete")
    private var interceptResultExpectation: XCTestExpectation?
    private var interceptedResult: URLRequest?

    func testWillSkipRequest() {
        willSkipRequestExpectation = expectation(description: "Will Skip Request")
        willSkipRequestExpectation?.assertForOverFulfill = false

        for _ in 1...5 {
            network.fetchRequest(requestForTestingWillSkip) { (result) in
                XCTAssertEqual(self.requestForTestingWillSkip, self.skippedRequest)
            }
        }

        wait(for: [willSkipRequestExpectation!], timeout: 5)
    }

    func testWillSendRequest() {
        willSendRequestExpectation = expectation(description: "Will Send Request")
        willSendRequestExpectation?.assertForOverFulfill = false

        network.fetchRequest(requestForTestingWillSend) { (result) in
            XCTAssertEqual(self.requestForTestingWillSend, self.sentRequest)
        }

        wait(for: [willSendRequestExpectation!], timeout: 5)
    }

    func testWillReceiveResult() {
        willReceiveResultExpectation = expectation(description: "Will Receive Request")

        network.fetchRequest(requestForTestingWillReceiveResult) { (result) in
            let r = try? result()
            XCTAssertEqual(r, self.receivedResult)
        }

        wait(for: [willReceiveResultExpectation!], timeout: 5)
    }

    func testInterceptRequest() {
        interceptRequestExpectation = expectation(description: "Intercept Request")

        network.fetchRequest(requestForTestingInterceptRequest) { (result) in
            XCTAssertEqual(self.interceptedRequest, self.requestForTestingWillSend)
        }

        wait(for: [interceptRequestExpectation!], timeout: 5)
    }

    func testInterceptResult() {
        interceptResultExpectation = expectation(description: "Intercept Result")

        network.fetchRequest(requestForTestingInterceptResult) { (result) in
            let message = "Should throw `CustomError.interceptedResult` here."
            do {
                let _ = try result()
                XCTAssert(false, message)
            } catch {
                XCTAssert(true, message)
                XCTAssertEqual(error as? CustomError, CustomError.interceptedResult)
            }
        }

        wait(for: [interceptResultExpectation!], timeout: 5)
    }

    func testDefaultNetworkFetchDelegate() {
        let defaultFetchDelegateExpectation = expectation(description: "Default Fetch Delegate")
        defaultFetchDelegateExpectation.assertForOverFulfill = false

        for _ in 1...5 {
            networkForTestingDefaultFetchDelegate.fetchRequest(requestForTestingWillSend) { (result) in
                do {
                    let _ = try result()
                    XCTAssert(true, "It should just work.")
                } catch {
                    XCTAssert(false, "It should not fail.")
                }
                defaultFetchDelegateExpectation.fulfill()
            }
        }

        wait(for: [defaultFetchDelegateExpectation], timeout: 5)
    }

    // MARK: NetworkFetchDelegate

    func willSkipRequest(_ request: URLRequest, sender: Network) {
        if request == requestForTestingWillSkip {
            skippedRequest = request
            willSkipRequestExpectation?.fulfill()
        }
    }

    func willSendRequest(_ request: URLRequest, sender: Network) {
        if request == requestForTestingWillSend {
            sentRequest = request
            willSendRequestExpectation?.fulfill()
        }
        if request == requestForTestingInterceptRequest {
            XCTAssert(false, "Should be intercepted and replaced with `requestForTestingWillSend`.")
        }
    }

    func willReceiveResult(_ result: () throws -> Network.FetchResult, from request: URLRequest, sender: Network) {
        if request == requestForTestingWillReceiveResult {
            receivedResult = try? result()
            willReceiveResultExpectation?.fulfill()
        }
    }

    func interceptRequest(_ request: URLRequest, sender: Network) throws -> URLRequest {
        if request == requestForTestingInterceptRequest {
            var newRequest = request
            newRequest.httpMethod = "GET"
            interceptedRequest = newRequest
            interceptRequestExpectation?.fulfill()
            return newRequest
        } else {
            return request
        }
    }

    func interceptResult(_ result: () throws -> Network.FetchResult, from request: URLRequest, sender: Network,
                         completion: @escaping Network.Completion.ThrowableFetchResult) {
        if request == requestForTestingInterceptResult {
            interceptResultExpectation?.fulfill()
            completion {
                throw CustomError.interceptedResult
            }
        } else {
            completion {
                try result()
            }
        }
    }

    private enum CustomError: Error {
        case interceptedResult
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
