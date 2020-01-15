/**
 *  https://github.com/tadija/AENetwork
 *  Copyright © 2017-2020 Marko Tadić
 *  Licensed under the MIT license
 */

import XCTest
@testable import AENetwork

class HTTPURLResponseTests: XCTestCase {

    static var allTests : [(String, (HTTPURLResponseTests) -> () throws -> Void)] {
        return [
            ("testCaseInsensitiveSearchOfHeaders", testCaseInsensitiveSearchOfHeaders),
            ("testShortDescription", testShortDescription)
        ]
    }

    // MARK: Tests

    func testCaseInsensitiveSearchOfHeaders() {
        let headers = [
            "x-custom-header" : "x-custom-value",
            "X-Another-Header" : "X-Another-Value"
        ]
        let response = HTTPURLResponse(url: "https://tadija.net", statusCode: 200,
                                       httpVersion: nil, headerFields: headers)!

        let message = "Should be able to find header with case insensitive search"
        XCTAssertEqual(response.headerValue(forKey: "X-Custom-Header") as! String, "x-custom-value", message)
        XCTAssertEqual(response.headerValue(forKey: "x-another-header") as! String, "X-Another-Value", message)
        XCTAssertNil(response.headerValue(forKey: "Not-Existing-Key"), "Should be nil.")
    }

    func testShortDescription() {
        let response = HTTPURLResponse(url: "https://tadija.net", statusCode: 200,
                                       httpVersion: nil, headerFields: nil)!
        XCTAssertEqual(response.shortDescription, "200 No Error")
    }

    func testFullDescription() {
        let response = HTTPURLResponse(url: "https://tadija.net", statusCode: 200,
                                       httpVersion: nil, headerFields: nil)!
        let fullDescription = """
        - Response: \(response.shortDescription)
        - Headers: [:]
        """
        XCTAssertEqual(response.fullDescription, fullDescription)
    }

}
