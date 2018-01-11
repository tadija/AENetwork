/**
 *  https://github.com/tadija/AENetwork
 *  Copyright (c) Marko Tadić 2017
 *  Licensed under the MIT license. See LICENSE file.
 */

import XCTest
@testable import AENetworkTests

XCTMain([
    testCase(NetworkTests.allTests),
    testCase(ReachabilityTests.allTests),
    testCase(FetcherTests.allTests),
    testCase(DownloaderTests.allTests),
    testCase(URLTests.allTests),
    testCase(URLRequestTests.allTests),
    testCase(HTTPURLResponseTests.allTests),
    testCase(SerializationTests.allTests)
])
