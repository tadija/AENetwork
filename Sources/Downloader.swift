/**
 *  https://github.com/tadija/AENetwork
 *  Copyright (c) Marko Tadić 2017
 *  Licensed under the MIT license. See LICENSE file.
 */

import Foundation

public protocol DownloadStatusDelegate {
    func didStartDownloadTask(_ task: URLSessionDownloadTask, sender: Downloader)
    func didUpdateDownloadTask(_ task: URLSessionDownloadTask, progress: Float, sender: Downloader)
    func didStopDownloadTask(_ task: URLSessionDownloadTask, sender: Downloader)
    func didFinishDownloadTask(_ task: URLSessionDownloadTask, to location: URL, sender: Downloader)
    func didFailDownloadTask(_ task: URLSessionTask, with error: Error?, sender: Downloader)
}

public protocol NetworkDownloaderDelegate: class, DownloadStatusDelegate { }

public protocol Downloadable: DownloadStatusDelegate {
    var downloadURL: URL? { get }
}

extension Downloadable {
    public func startDownload(with downloader: Downloader = .shared) {
        downloader.start(with: self)
    }
    public func stopDownload(with downloader: Downloader = .shared) {
        downloader.stop(for: self)
    }
    
    func didStartDownloadTask(_ task: URLSessionDownloadTask, sender: Downloader) {}
    func didUpdateDownloadTask(_ task: URLSessionDownloadTask, progress: Float, sender: Downloader) {}
    func didStopDownloadTask(_ task: URLSessionDownloadTask, sender: Downloader) {}
    func didFinishDownloadTask(_ task: URLSessionDownloadTask, to location: URL, sender: Downloader) {}
    func didFailDownloadTask(_ task: URLSessionTask, with error: Error?, sender: Downloader) {}
}

open class Downloader: NSObject {

    private static let sharedSessionID = "net.tadija.AENetwork.Downloader.shared"

    // MARK: Singleton
    
    public static let shared = Downloader(configuration: .background(withIdentifier: sharedSessionID))

    // MARK: Properties

    public weak var delegate: NetworkDownloaderDelegate?

    public private(set) var session: URLSession!
    public private(set) var tasks = [URLSessionDownloadTask]()

    public private(set) var items = [Downloadable]()

    // MARK: Init

    public init(configuration: URLSessionConfiguration) {
        super.init()
        self.session = URLSession(configuration: configuration, delegate: self, delegateQueue: .main)
    }

    public func cleanup() {
        session.finishTasksAndInvalidate()
    }

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
