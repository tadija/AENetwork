/**
 *  https://github.com/tadija/AENetwork
 *  Copyright © 2017-2020 Marko Tadić
 *  Licensed under the MIT license
 */

import XCTest
@testable import AENetwork

class URLRequestTests: XCTestCase {

    static var allTests: [(String, (URLRequestTests) -> () throws -> Void)] {
        [
            ("testGet", testGet),
            ("testPost", testPost),
            ("testPut", testPut),
            ("testPatch", testPatch),
            ("testDelete", testDelete),
            ("testEqualityWithBody", testEqualityWithBody)
        ]
    }

    // MARK: Properties

    let headers = ["Content-Type": "application/json"]
    let params = ["foo": "bar"]

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

    func testPatch() {
        let body = try? Data(jsonWith: params)
        let request = URLRequest.patch(url: "https://httpbin.org/patch", headers: headers, body: body)
        validateRequest(request, method: "PATCH", parametersType: .body)
    }

    func testDelete() {
        let body = try? Data(jsonWith: params)
        let request = URLRequest.delete(url: "https://httpbin.org/delete", headers: headers, body: body)
        validateRequest(request, method: "DELETE", parametersType: .body)
    }

    func testEqualityWithBody() {
        let r1 = URLRequest.post(
            url: "https://httpbin.org/post",
            headers: ["h1": "v1"],
            body: try? Data(jsonWith: ["id": "1"])
        )
        let r2 = URLRequest.post(
            url: "https://httpbin.org/post",
            headers: ["h1": "v1"],
            body: try? Data(jsonWith: ["id": "2"])
        )
        /// - Note: default Equatable implementation doesn't take `httpBody` into account
        XCTAssertEqual(r1, r2)

        /// - Note: so we need a custom `isEqual` helper for that
        XCTAssertFalse(r1.isEqual(to: r2))
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

        let requestHeaders = "\(request.allHTTPHeaderFields ?? [:])"
        let requestParameters = "\(request.url?.parameters ?? [:])"
        let requestBody = (try? request.httpBody?.jsonDictionary()) ?? [:]
        let fullDescription = """
        - Request: \(shortDescription)
        - Headers: \(requestHeaders)
        - Parameters: \(requestParameters)
        - Body: \(requestBody)
        """
        XCTAssertEqual(request.fullDescription, fullDescription)
    }

    private enum ParametersType {
        case url, body
    }

}
