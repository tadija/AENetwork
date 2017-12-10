/**
 *  https://github.com/tadija/AENetwork
 *  Copyright (c) Marko Tadić 2017
 *  Licensed under the MIT license. See LICENSE file.
 */

import XCTest
@testable import AENetwork

class DownloaderTests: XCTestCase {

    // MARK: Types

    struct Item: Downloadable {
        let downloadURL: URL?
    }

    // MARK: Properties

    let downloader = Downloader(sessionID: "net.tadija.AENetworkTests.Downloader")

    let url1 = URL(string: "https://httpbin.org/image/png")!
    let url2 = URL(string: "https://httpbin.org/image/jpeg")!

    // MARK: Setup

    override func setUp() {
        downloader.delegate = self
    }

    // MARK: Tests

    func testStartAndStopDownloadWithURL() {
        downloader.start(with: url1)
        XCTAssertNotNil(downloader.task(with: url1), "Should be able to find task with url.")
        XCTAssertEqual(downloader.tasks.count, 1, "Should have 1 download task.")

        downloader.start(with: url2)
        XCTAssertNotNil(downloader.task(with: url2), "Should be able to find task with url.")
        XCTAssertEqual(downloader.tasks.count, 2, "Should have 2 download tasks.")

        downloader.stop(for: url1)
        XCTAssertNil(downloader.task(with: url1), "Should not be able to find task with url.")
        XCTAssertEqual(downloader.tasks.count, 1, "Should have 1 download task.")

        downloader.stop(for: url2)
        XCTAssertNil(downloader.task(with: url2), "Should not be able to find task with url.")
        XCTAssertEqual(downloader.tasks.count, 0, "Should have 0 download tasks.")
    }

    func testStartAndStopDownloadWithItem() {
        let item1 = Item(downloadURL: url1)
        let item2 = Item(downloadURL: url2)

        let downloader = Downloader.shared

        item1.startDownload()
        XCTAssertNotNil(downloader.item(with: url1), "Should be able to find item with url.")
        XCTAssertEqual(downloader.items.count, 1, "Should have 1 download item.")

        item2.startDownload()
        XCTAssertNotNil(downloader.item(with: url2), "Should be able to find item with url.")
        XCTAssertEqual(downloader.items.count, 2, "Should have 2 download items.")

        item1.stopDownload()
        XCTAssertNil(downloader.item(with: url1), "Should not be able to find item with url.")
        XCTAssertEqual(downloader.items.count, 1, "Should have 1 download item.")

        item2.stopDownload()
        XCTAssertNil(downloader.item(with: url2), "Should not be able to find item with url.")
        XCTAssertEqual(downloader.items.count, 0, "Should have 0 download items.")
    }

    static var allTests : [(String, (DownloaderTests) -> () throws -> Void)] {
        return [
            ("testStartAndStopDownloadWithURL", testStartAndStopDownloadWithURL),
            ("testStartAndStopDownloadWithItem", testStartAndStopDownloadWithItem)
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
