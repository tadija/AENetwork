/**
 *  https://github.com/tadija/AENetwork
 *  Copyright (c) Marko Tadić 2017
 *  Licensed under the MIT license. See LICENSE file.
 */

import XCTest
@testable import AENetwork

class DownloaderTests: XCTestCase {

    // MARK: Properties

    let downloader = Downloader()

    // MARK: Setup

    override func setUp() {
        downloader.delegate = self
    }

    // MARK: Tests

    func testStartDownload() {
        let url = URL(string: "https://httpbin.org/image/png")!
        downloader.start(with: url)

        XCTAssertNotNil(downloader.task(with: url), "Should be able to find task with url.")
        XCTAssertEqual(downloader.tasks.count, 1, "Should have 1 download task.")
    }

    static var allTests : [(String, (DownloaderTests) -> () throws -> Void)] {
        return [
            ("testStartDownload", testStartDownload)
        ]
    }

}

extension DownloaderTests: NetworkDownloaderDelegate {

    func didStartDownloadTask(_ task: URLSessionDownloadTask, sender: Downloader) {

    }

    func didUpdateDownloadTask(_ task: URLSessionDownloadTask, progress: Float, sender: Downloader) {

    }

    func didStopDownloadTask(_ task: URLSessionDownloadTask, sender: Downloader) {

    }

    func didFinishDownloadTask(_ task: URLSessionDownloadTask, to location: URL, sender: Downloader) {

    }

    func didFailDownloadTask(_ task: URLSessionTask, with error: Error?, sender: Downloader) {

    }

}
