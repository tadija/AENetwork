/**
 *  https://github.com/tadija/AENetwork
 *  Copyright (c) Marko Tadić 2017
 *  Licensed under the MIT license. See LICENSE file.
 */

import XCTest
@testable import AENetwork

class URLRequestTests: XCTestCase {

    // MARK: Properties

    let headers = ["Content-Type" : "application/json"]
    let params = ["foo" : "bar"]

    // MARK: Tests

    func testGet() {
        let request = URLRequest.get(url: "https://httpbin.org/get", headers: headers, parameters: params)
        validateRequest(request, method: "GET", parametersType: .url)
    }

    func testPost() {
        let request = URLRequest.post(url: "https://httpbin.org/post", headers: headers, parameters: params)
        validateRequest(request, method: "POST", parametersType: .body)
    }

    func testPut() {
        let request = URLRequest.put(url: "https://httpbin.org/put", headers: headers, parameters: params)
        validateRequest(request, method: "PUT", parametersType: .body)
    }

    func testDelete() {
        let request = URLRequest.delete(url: "https://httpbin.org/delete", headers: headers, parameters: params)
        validateRequest(request, method: "DELETE", parametersType: .body)
    }

    static var allTests : [(String, (URLRequestTests) -> () throws -> Void)] {
        return [
            ("testGet", testGet),
            ("testPost", testPost),
            ("testPut", testPut),
            ("testDelete", testDelete)
        ]
    }

    // MARK: Helpers

    private func validateRequest(_ request: URLRequest, method: String, parametersType: ParametersType) {
        XCTAssertEqual(request.httpMethod, method, "Should have \(method) http method.")
        XCTAssertEqual(request.allHTTPHeaderFields!, headers, "Should have given header fields.")
        switch parametersType {
        case .url:
            XCTAssertEqual(request.url?.parameterValue(forKey: "foo"), "bar", "Should add parameters to URL.")
        case .body:
            XCTAssertEqual(request.httpBody, paramsBody, "Should add parameters to body.")
        }
    }

    private enum ParametersType {
        case url, body
    }

    private var paramsBody: Data? {
        return try? JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
    }

}
