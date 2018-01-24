/**
 *  https://github.com/tadija/AENetwork
 *  Copyright (c) Marko Tadić 2017-2018
 *  Licensed under the MIT license. See LICENSE file.
 */

import XCTest
@testable import AENetwork

class DownloaderTests: XCTestCase {

    // MARK: Types

    struct Item: Downloadable {
        let downloadURL: URL?

        var didStartExpectation: XCTestExpectation?
        var didUpdateExpectation: XCTestExpectation?
        var didStopExpectation: XCTestExpectation?
        var didFinishExpectation: XCTestExpectation?
        var didFailExpectation: XCTestExpectation?

        init(url: URL) {
            self.downloadURL = url
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

    // MARK: Setup

    override func setUp() {
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

        downloader.stop(for: url1)
        XCTAssertEqual(downloader.items.count, 1, "Should have 1 item.")
        XCTAssertNil(downloader.item(with: url1), "Should not be able to find item with url.")
        XCTAssertEqual(downloader.tasks.count, 1, "Should have 1 download task.")
        XCTAssertNil(downloader.task(with: url1), "Should not be able to find task with url.")

        item2.stopDownload(with: downloader)
        XCTAssertEqual(downloader.items.count, 0, "Should have 0 download items.")
        XCTAssertNil(downloader.item(with: url2), "Should not be able to find item with url.")
        XCTAssertEqual(downloader.tasks.count, 0, "Should have 0 download tasks.")
        XCTAssertNil(downloader.task(with: url2), "Should not be able to find task with url.")
    }

    var downloadFinishedExpectation: XCTestExpectation?

    func testDownloadFinished() {
        downloadFinishedExpectation = expectation(description: "Download Finished")
        downloadFinishedExpectation?.assertForOverFulfill = false
        downloader.start(with: url1)
        wait(for: [downloadFinishedExpectation!], timeout: 5)

        var item = Item(url: url2)
        item.didStartExpectation = expectation(description: "Item Started Download")
        item.didUpdateExpectation = expectation(description: "Item Updated Download")
        item.didUpdateExpectation?.assertForOverFulfill = false
        item.didFinishExpectation = expectation(description: "Item Finished Download")
        item.startDownload(with: downloader)
        let expectations = [item.didStartExpectation!, item.didUpdateExpectation!, item.didFinishExpectation!]
        wait(for: expectations, timeout: 5)
    }

    var downloadFailedExpectation: XCTestExpectation?

    func testDownloadFailed() {
        downloadFailedExpectation = expectation(description: "Download Failed")
        downloadFailedExpectation?.assertForOverFulfill = false
        downloader.start(with: url3)
        wait(for: [downloadFailedExpectation!], timeout: 5)

        var item = Item(url: url3)
        item.didStartExpectation = expectation(description: "Item Started Download")
        item.didFailExpectation = expectation(description: "Item Failed Download")
        item.startDownload(with: downloader)
        wait(for: [item.didStartExpectation!, item.didFailExpectation!], timeout: 5)
    }

    func testReplaceItem() {
        let item1 = Item(url: url1)
        downloader.start(with: item1)

        let item2 = Item(url: url2)
        downloader.replaceItem(at: 0, with: item2)

        XCTAssertNil(downloader.item(with: url1), "Should not be able to find item with url.")
        XCTAssertNotNil(downloader.item(with: url2), "Should be able to find item with url.")
        XCTAssertEqual(downloader.items.count, 1, "Should have 1 download item.")
    }

    func testCleanup() {
        class ClassUnderTest: Downloader {
            var deinitCalled: (() -> Void)?
            deinit { deinitCalled?() }
        }

        let deinitExpectation = expectation(description: "Deinit Called")

        var instance: ClassUnderTest? = ClassUnderTest(configuration: .default)
        instance?.deinitCalled = {
            deinitExpectation.fulfill()
        }

        DispatchQueue.global(qos: .background).async {
            /// - Note: In order for `Downloader` instance to be released `cleanup` must be called.
            /// That's because its `URLSession` has strong reference to it as its delegate.
            instance?.cleanup()
            instance = nil
        }

        wait(for: [deinitExpectation], timeout: 5)
    }

    static var allTests : [(String, (DownloaderTests) -> () throws -> Void)] {
        return [
            ("testStartAndStopDownload", testStartAndStopDownload),
            ("testDownloadFinished", testDownloadFinished),
            ("testDownloadFailed", testDownloadFailed),
            ("testReplaceItem", testReplaceItem),
            ("testCleanup", testCleanup)
        ]
    }

}

extension DownloaderTests: NetworkDownloaderDelegate {

    func didStartDownloadTask(_ task: URLSessionDownloadTask, sender: Downloader) {
        XCTAssertNotNil(downloader.tasks.index(of: task), "Should have this task in tasks.")
    }

    func didUpdateDownloadTask(_ task: URLSessionDownloadTask, progress: Float, sender: Downloader) {
        let message = "Progress should be between 0 and 1."
        XCTAssertGreaterThanOrEqual(progress, 0, message)
        XCTAssertLessThanOrEqual(progress, 1, message)
    }

    func didStopDownloadTask(_ task: URLSessionDownloadTask, sender: Downloader) {
        XCTAssertNil(downloader.tasks.index(of: task), "Should not have this task in tasks.")
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
