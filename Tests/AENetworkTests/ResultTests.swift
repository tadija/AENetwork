/**
 *  https://github.com/tadija/AENetwork
 *  Copyright (c) Marko Tadić 2017-2018
 *  Licensed under the MIT license. See LICENSE file.
 */

import XCTest
@testable import AENetwork

class ResultTests: XCTestCase {

    static var allTests : [(String, (ResultTests) -> () throws -> Void)] {
        return [
            ("testSuccess", testSuccess),
            ("testFailure", testFailure)
        ]
    }

    // MARK: Tests
    
    func testSuccess() {
        let value = "Value"
        let result = Result(value: value)
        
        XCTAssertNotNil(result.value)
        XCTAssertNil(result.error)
        XCTAssertEqual(value, result.value)
        XCTAssertTrue(result.isSuccess)
        XCTAssertFalse(result.isFailure)
        
        XCTAssertNoThrow(try result.throwValue())
        XCTAssertEqual(try? result.throwValue(), result.value)
    }
    
    func testFailure() {
        let error = NSError(domain: "net.tadija.AENetwork", code: 123, userInfo: nil)
        let result: Result<String> = Result(error: error)
        
        XCTAssertNotNil(result.error)
        XCTAssertNil(result.value)
        XCTAssertEqual(error, result.error! as NSError)
        XCTAssertTrue(result.isFailure)
        XCTAssertFalse(result.isSuccess)
        
        XCTAssertThrowsError(try result.throwValue(), "") { (throwedError) in
            XCTAssertEqual(throwedError as NSError, error)
        }
    }

}
