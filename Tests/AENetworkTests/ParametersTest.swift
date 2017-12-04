/**
 *  https://github.com/tadija/AENetwork
 *  Copyright (c) Marko Tadić 2017
 *  Licensed under the MIT license. See LICENSE file.
 */

import XCTest
@testable import AENetwork

class ParametersTests: XCTestCase {

    var url = URL(string: "https://httpbin.org")

    let parameters = [
        "foo" : "bar",
        "bar" : "foo"
    ]

    func testParameters() {
        let urlWithParameters = url?.addingParameters(parameters)

        XCTAssertEqual(urlWithParameters?.parameterValue(forKey: "foo"), "bar",
                       "Should be able to read parameter value.")

        XCTAssertEqual(urlWithParameters?.parameterValue(forKey: "bar"), "foo",
                       "Should be able to read parameter value.")

        XCTAssertNil(urlWithParameters?.parameterValue(forKey: "undefined"),
                     "Should return nil for not existing parameter.")
    }

    static var allTests : [(String, (ParametersTests) -> () throws -> Void)] {
        return [
            ("testParameters", testParameters)
        ]
    }

}
