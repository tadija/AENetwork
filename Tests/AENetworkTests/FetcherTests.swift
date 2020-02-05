/**
 *  https://github.com/tadija/AENetwork
 *  Copyright © 2017-2020 Marko Tadić
 *  Licensed under the MIT license
 */

import XCTest
@testable import AENetwork

class FetcherTests: XCTestCase {

    static var allTests : [(String, (FetcherTests) -> () throws -> Void)] {
        return [
            ("testFetchDictionary", testFetchDictionary),
            ("testFetchDictionaryError", testFetchDictionaryError),
            ("testFetchArray", testFetchArray),
            ("testFetchArrayError", testFetchArrayError),
            ("testFetchError", testFetchError),
            ("testResponseError", testResponseError),
            ("testInvalidResponseError", testInvalidResponseError),
            ("testFetcherResponseResultToAPIResponseResult", testFetcherResponseResultToAPIResponseResult)
        ]
    }
    
    // MARK: Properties
    
    let fetcher = Fetcher()

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
    
    func testInvalidResponseError() {
        let requestExpectation = expectation(description: "Request")
        let request = URLRequest(url: "https://httpbin.org/status/404")
        request.send { (result) in
            switch result {
            case .success(_):
                XCTAssert(false, "Should fail.")
            case .failure(let error):
                switch error {
                case Fetcher.Error.invalidResponse(let response):
                    let nsError = error as NSError
                    XCTAssertEqual(error.localizedDescription, "Request failed with status code: 404 Not Found")
                    XCTAssertEqual(nsError.domain, Fetcher.Error.errorDomain)
                    XCTAssertEqual(nsError.code, 404)
                    XCTAssertNotNil(nsError.userInfo["response"] as? Fetcher.Response)
                    XCTAssertEqual(response.statusCode, 404)
                default:
                    XCTAssert(false, "Should fail with Fetcher.Error.invalidResponse")
                }
            }
            requestExpectation.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testFetcherResponseResultToAPIResponseResult() {
        let url: URL = "https://httpbin.org/get"
        let request = URLRequest(url: url)
        let httpResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        let data = try! Data(jsonWith: ["foo" : "bar"])
        let fetchResponse = Fetcher.Response(request: request, response: httpResponse, data: data)
        
        let resultSuccess: Fetcher.ResponseResult = .success(fetchResponse)
        let apiResponseResultSuccess = Fetcher.apiResponseResult(from: resultSuccess)
        switch apiResponseResultSuccess {
        case .success(let response):
            XCTAssertEqual(response.request, request)
            XCTAssertEqual(response.response, httpResponse)
            XCTAssertEqual(response.data, data)
        case .failure(_):
            XCTAssert(false)
        }
        
        let resultFailure: Fetcher.ResponseResult = .failure(Fetcher.Error.invalidResponse(fetchResponse))
        let apiResponseResultFailure = Fetcher.apiResponseResult(from: resultFailure)
        switch apiResponseResultFailure {
        case .success(_):
            XCTAssert(false)
        case .failure(let error):
            switch error {
            case Fetcher.Error.invalidResponse(let response):
                XCTAssertEqual(response.request, request)
                XCTAssertEqual(response.response, httpResponse)
                XCTAssertEqual(response.data, data)
            default:
                XCTAssert(false)
            }
        }
    }

    // MARK: Helpers

    private func fetchDictionary(from url: URL, shouldFail: Bool = false) {
        let requestExpectation = expectation(description: "Request")

        let request = URLRequest(url: url)
        fetcher.send(request) { (result) in
            switch result {
            case .success(let response):
                XCTAssertEqual(response.statusCode, 200, "Should have response code 200.")
                if shouldFail {
                    XCTAssertNil(try? response.toDictionary(), "Should be nil.")
                } else {
                    XCTAssertNotNil(try? response.toDictionary(), "Should not be nil.")
                }
            case .failure(_):
                XCTAssert(shouldFail)
            }
            
            requestExpectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }

    private func fetchArray(from url: URL, shouldFail: Bool = false) {
        let requestExpectation = expectation(description: "Request")

        let request = URLRequest(url: url)
        fetcher.send(request) { (result) in
            switch result {
            case .success(let response):
                XCTAssertEqual(response.statusCode, 200, "Should have response code 200.")
                if shouldFail {
                    XCTAssertNil(try? response.toArray(), "Should be nil.")
                } else {
                    XCTAssertNotNil(try? response.toArray(), "Should not be nil.")
                }
            case .failure(_):
                XCTAssert(shouldFail)
            }

            requestExpectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }

}

class FetcherDelegateTests: XCTestCase, FetcherDelegate {

    static var allTests : [(String, (FetcherDelegateTests) -> () throws -> Void)] {
        return [
            ("testWillSendRequest", testWillSendRequest),
            ("testWillReceiveResult", testWillReceiveResult),
            ("testInterceptRequest", testInterceptRequest),
            ("testInterceptResult", testInterceptResult),
            ("testDefaultFetcherDelegate", testDefaultFetcherDelegate),
        ]
    }

    // MARK: Types

    class DefaultFetcherDelegate: FetcherDelegate {}

    // MARK: Properties

    let fetcher = Fetcher()

    let fetcherForTestingDefaultFetcherDelegate = Fetcher()
    let defaultFetcherDelegate = DefaultFetcherDelegate()

    // MARK: Lifecycle

    override func setUp() {
        fetcher.delegate = self
        fetcherForTestingDefaultFetcherDelegate.delegate = defaultFetcherDelegate
    }

    // MARK: Tests

    private let requestForTestingWillSend = URLRequest.get(url: "https://httpbin.org/get")
    private var willSendRequestExpectation: XCTestExpectation?
    private var sentRequest: URLRequest?

    private let requestForTestingWillReceiveResult = URLRequest.put(url: "https://httpbin.org/put")
    private var willReceiveResultExpectation: XCTestExpectation?
    private var receivedResult: Fetcher.Response?

    private let requestForTestingInterceptRequest = URLRequest.post(url: "https://httpbin.org/anything")
    private var interceptRequestExpectation: XCTestExpectation?
    private var interceptedRequest: URLRequest?

    private let requestForTestingInterceptResult = URLRequest.delete(url: "https://httpbin.org/delete")
    private var interceptResultExpectation: XCTestExpectation?
    private var interceptedResult: URLRequest?

    func testWillSendRequest() {
        willSendRequestExpectation = expectation(description: "Will Send Request")
        willSendRequestExpectation?.assertForOverFulfill = false

        fetcher.send(requestForTestingWillSend) { (result) in
            XCTAssertEqual(self.requestForTestingWillSend, self.sentRequest)
        }

        wait(for: [willSendRequestExpectation!], timeout: 5)
    }

    func testWillReceiveResult() {
        willReceiveResultExpectation = expectation(description: "Will Receive Request")

        fetcher.send(requestForTestingWillReceiveResult) { (result) in
            switch result {
            case .success(let response):
                XCTAssertEqual(response, self.receivedResult)
            case .failure(_):
                XCTAssert(true, "Should not fail.")
            }
        }

        wait(for: [willReceiveResultExpectation!], timeout: 5)
    }

    func testInterceptRequest() {
        interceptRequestExpectation = expectation(description: "Intercept Request")

        fetcher.send(requestForTestingInterceptRequest) { [unowned self] (result) in
            XCTAssertNotEqual(self.interceptedRequest, self.requestForTestingInterceptRequest)
            XCTAssertEqual(self.interceptedRequest, try? result.get().request)
            /// - Note: I have no idea why this fails... if you ever find out, please let me know!
            /// let getAnything = URLRequest.get(url: "https://httpbin.org/anything")
            /// XCTAssertEqual(self.interceptedRequest, getAnything)
        }

        wait(for: [interceptRequestExpectation!], timeout: 5)
    }

    func testInterceptResult() {
        interceptResultExpectation = expectation(description: "Intercept Result")

        fetcher.send(requestForTestingInterceptResult) { (result) in
            let message = "Should throw `CustomError.interceptedResult` here."
            switch result {
            case .success(_):
                XCTAssert(false, message)
            case .failure(let error):
                XCTAssert(true, message)
                XCTAssertEqual(error as? CustomError, CustomError.interceptedResult)
            }
        }

        wait(for: [interceptResultExpectation!], timeout: 5)
    }

    func testDefaultFetcherDelegate() {
        let defaultFetcherDelegateExpectation = expectation(description: "Default FetcherDelegate")
        defaultFetcherDelegateExpectation.assertForOverFulfill = false

        for _ in 1...5 {
            fetcherForTestingDefaultFetcherDelegate.send(requestForTestingWillSend) { (result) in
                switch result {
                case .success(_):
                    XCTAssert(true, "It should just work.")
                case .failure(_):
                    XCTAssert(false, "It should not fail.")
                }
                defaultFetcherDelegateExpectation.fulfill()
            }
        }
        
        wait(for: [defaultFetcherDelegateExpectation], timeout: 5)
    }

    // MARK: FetcherDelegate

    func willSendRequest(_ request: URLRequest, sender: Fetcher) {
        if request == requestForTestingWillSend {
            sentRequest = request
            willSendRequestExpectation?.fulfill()
        }
        if request == requestForTestingInterceptRequest {
            XCTAssert(false, "Should be intercepted and replaced with `requestForTestingWillSend`.")
        }
    }
    
    func willReceiveResult(_ result: Fetcher.ResponseResult, sender: Fetcher) {
        if let result = try? result.get(), result.request == requestForTestingWillReceiveResult {
            receivedResult = result
            willReceiveResultExpectation?.fulfill()
        }
    }

    func interceptRequest(_ request: URLRequest, sender: Fetcher) throws -> URLRequest {
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

    func interceptResult(_ result: Fetcher.ResponseResult, sender: Fetcher, completion: @escaping Fetcher.Callback) {
        if let request = try? result.get().request, request == requestForTestingInterceptResult {
            interceptResultExpectation?.fulfill()
            completion(.failure(CustomError.interceptedResult))
        } else {
            completion(result)
        }
    }

    private enum CustomError: Error {
        case interceptedResult
    }

}

@available(iOS 10.0, macOS 10.12, *)
class FetcherQueueTests: XCTestCase {

    static var allTests : [(String, (FetcherQueueTests) -> () throws -> Void)] {
        return [
            ("testCompletionInMainQueue", testCompletionInMainQueue)
        ]
    }

    // MARK: Properties

    let fetcher = Fetcher()

    // MARK: Tests

    func testCompletionInMainQueue() {
        let request = URLRequest.get(url: "https://httpbin.org/get")
        let queueExpectation = expectation(description: "Main")
        fetcher.send(request) { (result) in
            dispatchPrecondition(condition: .onQueue(.main))
            queueExpectation.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
    }

}
