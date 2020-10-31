/**
 *  https://github.com/tadija/AENetwork
 *  Copyright © 2017-2020 Marko Tadić
 *  Licensed under the MIT license
 */

import Foundation

// MARK: - Downloadable

public protocol Downloadable: DownloadStatusDelegate {
    var downloadRequest: URLRequest? { get }
}

public protocol DownloadStatusDelegate {
    func didStartDownloadTask(
        _ task: URLSessionDownloadTask, sender: Downloader
    )
    func didUpdateDownloadTask(
        _ task: URLSessionDownloadTask, progress: Float, sender: Downloader
    )
    func didStopDownloadTask(
        _ task: URLSessionDownloadTask, sender: Downloader
    )
    func didFinishDownloadTask(
        _ task: URLSessionDownloadTask, to location: URL, sender: Downloader
    )
    func didFailDownloadTask(
        _ task: URLSessionTask, with error: Error?, sender: Downloader
    )
}

extension Downloadable {
    public func didStartDownloadTask(
        _ task: URLSessionDownloadTask, sender: Downloader) {}
    public func didUpdateDownloadTask(
        _ task: URLSessionDownloadTask, progress: Float, sender: Downloader) {}
    public func didStopDownloadTask(
        _ task: URLSessionDownloadTask, sender: Downloader) {}
    public func didFinishDownloadTask(
        _ task: URLSessionDownloadTask, to location: URL, sender: Downloader) {}
    public func didFailDownloadTask(
        _ task: URLSessionTask, with error: Error?, sender: Downloader) {}

    public func startDownload(with downloader: Downloader) {
        downloader.start(with: self)
    }
    public func stopDownload(with downloader: Downloader) {
        downloader.stop(for: self)
    }
}

extension URL: Downloadable {
    public var downloadRequest: URLRequest? {
        URLRequest(url: self)
    }
}

extension URLRequest: Downloadable {
    public var downloadRequest: URLRequest? {
        self
    }
}

// MARK: - Downloader

public protocol DownloaderDelegate: class, DownloadStatusDelegate {}

open class Downloader: NSObject {

    public static let defaultConfiguration: URLSessionConfiguration = .background(
        withIdentifier: "AENetwork.Downloader"
    )

    // MARK: Properties

    public private(set) var items = [Downloadable]()
    public weak var delegate: DownloaderDelegate?

    public private(set) var session: URLSession!
    public private(set) var tasks = [URLSessionDownloadTask]()

    // MARK: Init

    public init(configuration: URLSessionConfiguration = defaultConfiguration) {
        super.init()
        self.session = URLSession(
            configuration: configuration, delegate: self, delegateQueue: .main
        )
    }

    public func cleanup() {
        session.finishTasksAndInvalidate()
    }

    // MARK: API / Download

    public func start(with item: Downloadable) {
        if let url = item.downloadRequest {
            items.append(item)
            start(with: url)
        }
    }

    public func stop(for item: Downloadable) {
        if let url = item.downloadRequest {
            stop(for: url)
        }
    }

    // MARK: API / Helpers

    public func task(with request: URLRequest) -> URLSessionDownloadTask? {
        tasks.first(where: { $0.originalRequest == request })
    }

    public func task(with url: URL) -> URLSessionDownloadTask? {
        tasks.first(where: { $0.originalRequest == url.downloadRequest })
    }

    public func item(with request: URLRequest) -> Downloadable? {
        items.first(where: { $0.downloadRequest == request })
    }

    public func item(with url: URL) -> Downloadable? {
        items.first(where: { $0.downloadRequest == url.downloadRequest })
    }

    public func replaceItem(at index: Int, with item: Downloadable) {
        if items.indices.contains(index) {
            items[index] = item
        }
    }

    // MARK: Helpers

    private func start(with request: URLRequest) {
        let task = session.downloadTask(with: request)
        tasks.append(task)
        task.resume()

        delegate?.didStartDownloadTask(task, sender: self)
        if let item = item(with: request) {
            item.didStartDownloadTask(task, sender: self)
        }
    }

    private func stop(for request: URLRequest) {
        if let task = task(with: request) {
            task.cancel()
            let stoppedItem = item(with: task)
            performCleanup(for: task)

            delegate?.didStopDownloadTask(task, sender: self)
            stoppedItem?.didStopDownloadTask(task, sender: self)
        }
    }

    fileprivate func performCleanup(for task: URLSessionTask) {
        if let taskIndex = tasks.firstIndex(where: { $0.originalRequest?.url == task.originalRequest?.url }) {
            tasks.remove(at: taskIndex)
        }
        if let itemIndex = items.firstIndex(where: { $0.downloadRequest == task.originalRequest }) {
            items.remove(at: itemIndex)
        }
    }

    fileprivate func item(with task: URLSessionTask) -> Downloadable? {
        items.first(where: { $0.downloadRequest == task.originalRequest })
    }

}

extension Downloader: URLSessionDelegate, URLSessionDownloadDelegate {

    // MARK: URLSessionDownloadDelegate

    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,
                           didWriteData bytesWritten: Int64,
                           totalBytesWritten: Int64,
                           totalBytesExpectedToWrite: Int64) {
        if totalBytesExpectedToWrite > 0 {
            let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
            delegate?.didUpdateDownloadTask(downloadTask, progress: progress, sender: self)
            if let item = item(with: downloadTask) {
                item.didUpdateDownloadTask(downloadTask, progress: progress, sender: self)
            }
        }
    }

    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,
                           didFinishDownloadingTo location: URL) {
        let finishedItem = item(with: downloadTask)
        performCleanup(for: downloadTask)

        delegate?.didFinishDownloadTask(downloadTask, to: location, sender: self)
        finishedItem?.didFinishDownloadTask(downloadTask, to: location, sender: self)
    }

    // MARK: URLSessionTaskDelegate

    public func urlSession(_ session: URLSession, task: URLSessionTask,
                           didCompleteWithError error: Error?) {
        let failedItem = item(with: task)
        performCleanup(for: task)

        delegate?.didFailDownloadTask(task, with: error, sender: self)
        failedItem?.didFailDownloadTask(task, with: error, sender: self)
    }

}
