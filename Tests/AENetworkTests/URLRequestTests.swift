/**
 *  https://github.com/tadija/AENetwork
 *  Copyright (c) Marko Tadić 2017-2019
 *  Licensed under the MIT license. See LICENSE file.
 */

import XCTest
@testable import AENetwork

class URLRequestTests: XCTestCase {

    static var allTests : [(String, (URLRequestTests) -> () throws -> Void)] {
        return [
            ("testGet", testGet),
            ("testPost", testPost),
            ("testPut", testPut),
            ("testDelete", testDelete)
        ]
    }

    // MARK: Properties

    let headers = ["Content-Type" : "application/json"]
    let params = ["foo" : "bar"]

    // MARK: Tests

    func testGet() {
        let request = URLRequest.get(url: "https://httpbin.org/get", headers: headers, urlParameters: params)
        validateRequest(request, method: "GET", parametersType: .url)
    }

    func testPost() {
        let body = try? Data(jsonWith: params)
        let request = URLRequest.post(url: "https://httpbin.org/post", headers: headers, body: body)
        validateRequest(request, method: "POST", parametersType: .body)
    }

    func testPut() {
        let body = try? Data(jsonWith: params)
        let request = URLRequest.put(url: "https://httpbin.org/put", headers: headers, body: body)
        validateRequest(request, method: "PUT", parametersType: .body)
    }

    func testDelete() {
        let body = try? Data(jsonWith: params)
        let request = URLRequest.delete(url: "https://httpbin.org/delete", headers: headers, body: body)
        validateRequest(request, method: "DELETE", parametersType: .body)
    }

    // MARK: Helpers

    private func validateRequest(_ request: URLRequest, method: String, parametersType: ParametersType) {
        XCTAssertEqual(request.httpMethod, method, "Should have \(method) http method.")
        XCTAssertEqual(request.allHTTPHeaderFields!, headers, "Should have given header fields.")
        switch parametersType {
        case .url:
            XCTAssertEqual(request.url?.value(forParameterKey: "foo"), "bar", "Should add parameters to URL.")
        case .body:
            XCTAssertEqual(request.httpBody, try? Data(jsonWith: params), "Should add parameters to body.")
        }

        let shortDescription = "\(method) \(request.url?.absoluteString ?? "n/a")"
        XCTAssertEqual(request.shortDescription, shortDescription)

        let requestHeaders = "\(request.allHTTPHeaderFields ?? [String : String]())"
        let requestParameters = "\(request.url?.parameters ?? [String : String]())"
        let fullDescription = """
        - Request: \(shortDescription)
        - Headers: \(requestHeaders)
        - Parameters: \(requestParameters)
        """
        XCTAssertEqual(request.fullDescription, fullDescription)
    }

    private enum ParametersType {
        case url, body
    }

}
