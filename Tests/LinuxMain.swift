/**
 *  https://github.com/tadija/AENetwork
 *  Copyright © 2017-2020 Marko Tadić
 *  Licensed under the MIT license
 */

import XCTest
@testable import AENetworkTests

XCTMain([
    testCase(ResultTests.allTests),
    testCase(APIClientTests.allTests),
    testCase(NetworkTests.allTests),
    testCase(ReachabilityTests.allTests),
    testCase(FetcherTests.allTests),
    testCase(DownloaderTests.allTests),
    testCase(URLTests.allTests),
    testCase(URLRequestTests.allTests),
    testCase(HTTPURLResponseTests.allTests),
    testCase(DataTests.allTests)
])
