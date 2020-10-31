/**
 *  https://github.com/tadija/AENetwork
 *  Copyright © 2017-2020 Marko Tadić
 *  Licensed under the MIT license
 */

import XCTest
@testable import AENetwork

class DownloaderTests: XCTestCase {

    static var allTests: [(String, (DownloaderTests) -> () throws -> Void)] {
        [
            ("testStartAndStopDownload", testStartAndStopDownload),
            ("testDownloadFinished", testDownloadFinished),
            ("testDownloadFailed", testDownloadFailed),
            ("testReplaceItem", testReplaceItem)
        ]
    }

    // MARK: Types

    struct Item: Downloadable {
        let downloadRequest: URLRequest?

        var didStartExpectation: XCTestExpectation?
        var didUpdateExpectation: XCTestExpectation?
        var didStopExpectation: XCTestExpectation?
        var didFinishExpectation: XCTestExpectation?
        var didFailExpectation: XCTestExpectation?

        init(url: URL) {
            self.downloadRequest = url.downloadRequest
        }

        init(request: URLRequest) {
            self.downloadRequest = request
        }

        func didStartDownloadTask(_ task: URLSessionDownloadTask, sender: Downloader) {
            didStartExpectation?.fulfill()
        }
        func didUpdateDownloadTask(_ task: URLSessionDownloadTask, progress: Float, sender: Downloader) {
            didUpdateExpectation?.fulfill()
        }
        func didStopDownloadTask(_ task: URLSessionDownloadTask, sender: Downloader) {
            didStopExpectation?.fulfill()
        }
        func didFinishDownloadTask(_ task: URLSessionDownloadTask, to location: URL, sender: Downloader) {
            didFinishExpectation?.fulfill()
        }
        func didFailDownloadTask(_ task: URLSessionTask, with error: Error?, sender: Downloader) {
            didFailExpectation?.fulfill()
        }
    }

    // MARK: Properties

    let downloader = Downloader(configuration: .default)

    let url1: URL = "https://httpbin.org/image/png"
    let url2: URL = "https://httpbin.org/image/jpeg"
    let url3: URL = "https://test.test"
    let request1 = URLRequest(url: "https://httpbin.org/image/svg")
    let request2 = URLRequest(url: "https://test.request")

    // MARK: Setup

    override func setUp() {
        super.setUp()

        downloader.delegate = self
    }

    // MARK: Tests

    func testStartAndStopDownload() {
        downloader.start(with: url1)
        XCTAssertEqual(downloader.items.count, 1, "Should have 1 item.")
        XCTAssertNotNil(downloader.item(with: url1), "Should be able to find item with url.")
        XCTAssertEqual(downloader.tasks.count, 1, "Should have 1 download task.")
        XCTAssertNotNil(downloader.task(with: url1), "Should be able to find task with url.")

        let item2 = Item(url: url2)
        item2.startDownload(with: downloader)
        XCTAssertEqual(downloader.items.count, 2, "Should have 2 download items.")
        XCTAssertNotNil(downloader.item(with: url2), "Should be able to find item with url.")
        XCTAssertEqual(downloader.tasks.count, 2, "Should have 2 download tasks.")
        XCTAssertNotNil(downloader.task(with: url2), "Should be able to find task with url.")

        let item3 = Item(request: request1)
        item3.startDownload(with: downloader)
        XCTAssertEqual(downloader.items.count, 3, "Should have 3 download items.")
        XCTAssertNotNil(downloader.item(with: request1), "Should be able to find item with request.")
        XCTAssertEqual(downloader.tasks.count, 3, "Should have 3 download tasks.")
        XCTAssertNotNil(downloader.task(with: request1), "Should be able to find task with request.")

        downloader.stop(for: url1)
        XCTAssertEqual(downloader.items.count, 2, "Should have 2 item.")
        XCTAssertNil(downloader.item(with: url1), "Should not be able to find item with url.")
        XCTAssertEqual(downloader.tasks.count, 2, "Should have 2 download task.")
        XCTAssertNil(downloader.task(with: url1), "Should not be able to find task with url.")

        item2.stopDownload(with: downloader)
        XCTAssertEqual(downloader.items.count, 1, "Should have 1 download items.")
        XCTAssertNil(downloader.item(with: url2), "Should not be able to find item with url.")
        XCTAssertEqual(downloader.tasks.count, 1, "Should have 1 download tasks.")
        XCTAssertNil(downloader.task(with: url2), "Should not be able to find task with url.")

        item3.stopDownload(with: downloader)
        XCTAssertEqual(downloader.items.count, 0, "Should have 0 download items.")
        XCTAssertNil(downloader.item(with: request1), "Should not be able to find item with request.")
        XCTAssertEqual(downloader.tasks.count, 0, "Should have 0 download tasks.")
        XCTAssertNil(downloader.task(with: request1), "Should not be able to find task with request.")
    }

    var downloadFinishedExpectation: XCTestExpectation?

    func testDownloadFinished() {
        downloadFinishedExpectation = expectation(description: "Download Finished")
        downloadFinishedExpectation?.assertForOverFulfill = false
        downloader.start(with: url1)
        wait(for: [downloadFinishedExpectation!], timeout: 5)

        var item2 = Item(url: url2)
        item2.didStartExpectation = expectation(description: "Item Started Download")
        item2.didUpdateExpectation = expectation(description: "Item Updated Download")
        item2.didUpdateExpectation?.assertForOverFulfill = false
        item2.didFinishExpectation = expectation(description: "Item Finished Download")
        item2.startDownload(with: downloader)
        let expectations2 = [item2.didStartExpectation!, item2.didUpdateExpectation!, item2.didFinishExpectation!]
        wait(for: expectations2, timeout: 5)

        var item3 = Item(request: request1)
        item3.didStartExpectation = expectation(description: "Item Started Download")
        item3.didUpdateExpectation = expectation(description: "Item Updated Download")
        item3.didUpdateExpectation?.assertForOverFulfill = false
        item3.didFinishExpectation = expectation(description: "Item Finished Download")
        item3.startDownload(with: downloader)
        let expectations3 = [item3.didStartExpectation!, item3.didUpdateExpectation!, item3.didFinishExpectation!]
        wait(for: expectations3, timeout: 5)
    }

    var downloadFailedExpectation: XCTestExpectation?

    func testDownloadFailed() {
        downloadFailedExpectation = expectation(description: "Download Failed")
        downloadFailedExpectation?.assertForOverFulfill = false
        downloader.start(with: url3)
        wait(for: [downloadFailedExpectation!], timeout: 5)

        var item2 = Item(url: url3)
        item2.didStartExpectation = expectation(description: "Item Started Download")
        item2.didFailExpectation = expectation(description: "Item Failed Download")
        item2.startDownload(with: downloader)
        wait(for: [item2.didStartExpectation!, item2.didFailExpectation!], timeout: 5)

        var item3 = Item(request: request2)
        item3.didStartExpectation = expectation(description: "Item Started Download")
        item3.didFailExpectation = expectation(description: "Item Failed Download")
        item3.startDownload(with: downloader)
        wait(for: [item3.didStartExpectation!, item3.didFailExpectation!], timeout: 5)
    }

    func testReplaceItem() {
        let item1 = Item(url: url1)
        downloader.start(with: item1)

        let item2 = Item(url: url2)
        downloader.replaceItem(at: 0, with: item2)

        let item3 = Item(url: url3)
        downloader.start(with: item3)

        let item4 = Item(request: request1)
        downloader.replaceItem(at: 1, with: item4)

        XCTAssertNil(downloader.item(with: url1), "Should not be able to find item with url.")
        XCTAssertNil(downloader.item(with: url3), "Should not be able to find item with url.")
        XCTAssertNotNil(downloader.item(with: url2), "Should be able to find item with url.")
        XCTAssertNotNil(downloader.item(with: request1), "Should be able to find item with request.")
        XCTAssertEqual(downloader.items.count, 2, "Should have 1 download item.")
    }

}

extension DownloaderTests: DownloaderDelegate {

    func didStartDownloadTask(_ task: URLSessionDownloadTask, sender: Downloader) {
        XCTAssertNotNil(downloader.tasks.firstIndex(of: task), "Should have this task in tasks.")
    }

    func didUpdateDownloadTask(_ task: URLSessionDownloadTask, progress: Float, sender: Downloader) {
        let message = "Progress should be between 0 and 1."
        XCTAssertGreaterThanOrEqual(progress, 0, message)
        XCTAssertLessThanOrEqual(progress, 1, message)
    }

    func didStopDownloadTask(_ task: URLSessionDownloadTask, sender: Downloader) {
        XCTAssertNil(downloader.tasks.firstIndex(of: task), "Should not have this task in tasks.")
    }

    func didFinishDownloadTask(_ task: URLSessionDownloadTask, to location: URL, sender: Downloader) {
        let isDownloaded = FileManager.default.fileExists(atPath: location.path)
        XCTAssertTrue(isDownloaded, "Should have downloaded file at location: \(location).")
        downloadFinishedExpectation?.fulfill()
    }

    func didFailDownloadTask(_ task: URLSessionTask, with error: Error?, sender: Downloader) {
        if task.originalRequest?.url == url3 {
            XCTAssertNotNil(error, "Should have error: \(String(describing: error?.localizedDescription))")
            downloadFailedExpectation?.fulfill()
        }
    }

}
