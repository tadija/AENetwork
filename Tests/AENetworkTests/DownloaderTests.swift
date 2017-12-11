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

    let url1 = URL(string: "https://httpbin.org/image/png")!
    let url2 = URL(string: "https://httpbin.org/image/jpeg")!
    let url3 = URL(string: "https://httpbin.org/image/svg")!
    let url4 = URL(string: "https://test.test")!

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
        let item1 = Item(url: url1)
        let item2 = Item(url: url2)

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

    var downloadFinishedExpectation: XCTestExpectation?

    func testDownloadFinishedDelegateCallback() {
        downloadFinishedExpectation = expectation(description: "Download Finished")
        downloader.start(with: url3)
        wait(for: [downloadFinishedExpectation!], timeout: 5)
    }

    var downloadErrorExpectation: XCTestExpectation?

    func testDownloadErrorDelegateCallback() {
        downloadErrorExpectation = expectation(description: "Download Error")
        downloader.start(with: url4)
        wait(for: [downloadErrorExpectation!], timeout: 5)
    }

    func testDownloadFinishedWithItem() {
        var item = Item(url: url3)
        item.didStartExpectation = expectation(description: "Item Started Download")
        item.didUpdateExpectation = expectation(description: "Item Updated Download")
        item.didUpdateExpectation?.assertForOverFulfill = false
        item.didFinishExpectation = expectation(description: "Item Finished Download")
        item.startDownload(with: downloader)
        let expectations = [item.didStartExpectation!, item.didUpdateExpectation!, item.didFinishExpectation!]
        wait(for: expectations, timeout: 5)
    }

    func testDownloadFailWithItem() {
        var item = Item(url: url4)
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
            ("testStartAndStopDownloadWithURL", testStartAndStopDownloadWithURL),
            ("testStartAndStopDownloadWithItem", testStartAndStopDownloadWithItem),
            ("testDownloadFinishedDelegateCallback", testDownloadFinishedDelegateCallback),
            ("testDownloadErrorDelegateCallback", testDownloadErrorDelegateCallback),
            ("testDownloadFinishedWithItem", testDownloadFinishedWithItem),
            ("testDownloadFailWithItem", testDownloadFailWithItem),
            ("testReplaceItem", testReplaceItem),
            ("testCleanup", testCleanup)
        ]
    }

}

extension DownloaderTests: NetworkDownloaderDelegate {

    func didStartDownloadTask(_ task: URLSessionDownloadTask, sender: Downloader) {

    }

    func didUpdateDownloadTask(_ task: URLSessionDownloadTask, progress: Float, sender: Downloader) {
        let message = "Progress should be between 0 and 1."
        XCTAssertGreaterThanOrEqual(progress, 0, message)
        XCTAssertLessThanOrEqual(progress, 1, message)
    }

    func didStopDownloadTask(_ task: URLSessionDownloadTask, sender: Downloader) {

    }

    func didFinishDownloadTask(_ task: URLSessionDownloadTask, to location: URL, sender: Downloader) {
        let isDownloaded = FileManager.default.fileExists(atPath: location.path)
        XCTAssertTrue(isDownloaded, "Should have downloaded file at location: \(location).")
        downloadFinishedExpectation?.fulfill()
    }

    func didFailDownloadTask(_ task: URLSessionTask, with error: Error?, sender: Downloader) {
        if task.originalRequest?.url == url4 {
            XCTAssertNotNil(error, "Should have error: \(String(describing: error?.localizedDescription))")
            downloadErrorExpectation?.fulfill()
        }
    }

}
