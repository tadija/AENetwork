/**
 *  https://github.com/tadija/AENetwork
 *  Copyright (c) Marko Tadić 2017
 *  Licensed under the MIT license. See LICENSE file.
 */

import XCTest
@testable import AENetwork

class URLTests: XCTestCase {

    // MARK: Properties

    var url: URL = "https://httpbin.org"

    let parameters = [
        "foo" : "bar",
        "bar" : "foo",
        "true" : "true",
        "false" : "false",
        "int" : "21",
        "double" : "8.0"
    ]

    // MARK: Tests

    func testReadingParameters() {
        let urlWithParameters = url.addingParameters(parameters)

        XCTAssertEqual(urlWithParameters?.parameterValue(forKey: "foo"), "bar",
                       "Should be able to read parameter value.")

        XCTAssertEqual(urlWithParameters?.parameterValue(forKey: "bar"), "foo",
                       "Should be able to read parameter value.")

        XCTAssertNil(urlWithParameters?.parameterValue(forKey: "undefined"),
                     "Should return nil for not existing parameter.")
    }

    func testParameterTypes() {
        let urlWithParameters = url.addingParameters(parameters)

        XCTAssertEqual(urlWithParameters?.stringValue(forParameterKey: "foo"), "bar",
                       "Should be able to parse String parameter.")
        XCTAssertEqual(urlWithParameters?.stringValue(forParameterKey: "undefined"), "",
                       "Should be able to return empty String.")
        
        XCTAssertEqual(urlWithParameters?.boolValue(forParameterKey: "true"), true,
                       "Should be able to parse Bool parameter.")
        XCTAssertEqual(urlWithParameters?.boolValue(forParameterKey: "false"), false,
                       "Should be able to parse Bool parameter.")
        XCTAssertEqual(urlWithParameters?.intValue(forParameterKey: "int"), 21,
                       "Should be able to parse Int parameter.")
        XCTAssertEqual(urlWithParameters?.doubleValue(forParameterKey: "double"), 8.0, "Should be able to parse Double parameter.")

        XCTAssertNil(urlWithParameters?.boolValue(forParameterKey: "foo"),
                     "Should not be able to parse Bool parameter.")
        XCTAssertNil(urlWithParameters?.intValue(forParameterKey: "foo"),
                     "Should not be able to parse Int parameter.")
        XCTAssertNil(urlWithParameters?.doubleValue(forParameterKey: "foo"),
                     "Should not be able to parse Double parameter.")
    }

    static var allTests : [(String, (URLTests) -> () throws -> Void)] {
        return [
            ("testReadingParameters", testReadingParameters)
        ]
    }

}
