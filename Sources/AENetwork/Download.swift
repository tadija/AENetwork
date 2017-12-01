/**
 *  https://github.com/tadija/AENetwork
 *  Copyright (c) Marko Tadić 2017
 *  Licensed under the MIT license. See LICENSE file.
 */

import Foundation

public protocol NetworkDownloadDelegate: class {
    func didStartDownloadTask(_ task: URLSessionDownloadTask, sender: Download)
    func didUpdateDownloadTask(_ task: URLSessionDownloadTask, progress: Float, sender: Download)
    func didStopDownloadTask(_ task: URLSessionDownloadTask, sender: Download)
    func didFinishDownloadTask(_ task: URLSessionDownloadTask, to location: URL, sender: Download)
    func didFailDownloadTask(_ task: URLSessionTask, with error: Error?, sender: Download)
}

public protocol Downloadable: NetworkDownloadDelegate {
    var downloadURL: URL? { get }
}

extension Downloadable {
    public func startDownload() {
        Download.shared.start(with: self)
    }
    public func stopDownload() {
        Download.shared.stop(for: self)
    }
}

open class Download: NSObject {

    // MARK: Singleton

    public static let shared = Download()

    // MARK: Properties

    public weak var delegate: NetworkDownloadDelegate?

    private lazy var session: URLSession = {
        let identifier = "net.tadija.AENetwork.DownloadManager"
        let config = URLSessionConfiguration.background(withIdentifier: identifier)
        let session = URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue.main)
        return session
    }()

    private var tasks = [URLSessionDownloadTask]()

    public private(set) var items = [Downloadable]()

    // MARK: API / URL

    public func start(with url: URL) {
        let task = session.downloadTask(with: url)
        tasks.append(task)
        task.resume()

        delegate?.didStartDownloadTask(task, sender: self)
        if let item = item(with: url) {
            item.didStartDownloadTask(task, sender: self)
        }
    }

    public func stop(for url: URL) {
        if let task = task(with: url) {
            task.cancel()
            delegate?.didStopDownloadTask(task, sender: self)
            if let item = item(with: task) {
                item.didStopDownloadTask(task, sender: self)
            }
            performCleanup(for: task)
        }
    }

    // MARK: API / Downloadable

    public func start(with item: Downloadable) {
        if let url = item.downloadURL {
            items.append(item)
            start(with: url)
        }
    }

    public func stop(for item: Downloadable) {
        if let url = item.downloadURL {
            stop(for: url)
        }
    }

    // MARK: API / Helpers

    public func task(with url: URL) -> URLSessionDownloadTask? {
        let task = tasks.filter({ $0.originalRequest?.url == url }).first
        return task
    }

    public func item(with url: URL) -> Downloadable? {
        let item = items.filter({ $0.downloadURL == url }).first
        return item
    }

    public func replaceItem(at index: Int, with item: Downloadable) {
        if items.indices.contains(index) {
            items[index] = item
        }
    }

    // MARK: Helpers

    fileprivate func performCleanup(for task: URLSessionTask) {
        if let taskIndex = tasks.index(where: { $0.originalRequest?.url == task.originalRequest?.url }) {
            tasks.remove(at: taskIndex)
        }
        if let itemIndex = items.index(where: { $0.downloadURL == task.originalRequest?.url }) {
            items.remove(at: itemIndex)
        }
    }

    fileprivate func item(with task: URLSessionTask) -> Downloadable? {
        let item = items.filter({ $0.downloadURL == task.originalRequest?.url }).first
        return item
    }

}

extension Download: URLSessionDelegate, URLSessionDownloadDelegate {

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
        delegate?.didFinishDownloadTask(downloadTask, to: location, sender: self)
        if let item = item(with: downloadTask) {
            item.didFinishDownloadTask(downloadTask, to: location, sender: self)
        }
        performCleanup(for: downloadTask)
    }

    // MARK: URLSessionTaskDelegate

    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        delegate?.didFailDownloadTask(task, with: error, sender: self)
        if let item = item(with: task) {
            item.didFailDownloadTask(task, with: error, sender: self)
        }
        performCleanup(for: task)
    }

}
