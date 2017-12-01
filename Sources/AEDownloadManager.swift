//
// AEDownloadManager.swift
//
// Copyright (c) 2017 Marko TadiÄ‡ <tadija@me.com> http://tadija.net
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

import Foundation

public protocol AEDownloadManagerDelegate: class {
    func didStartDownloadTask(_ task: URLSessionDownloadTask)
    func didUpdateDownloadTask(_ task: URLSessionDownloadTask, progress: Float)
    func didStopDownloadTask(_ task: URLSessionDownloadTask)
    func didFinishDownloadTask(_ task: URLSessionDownloadTask, to location: URL)
    func didFailDownloadTask(_ task: URLSessionTask, with error: Error?)
}

public protocol Downloadable: AEDownloadManagerDelegate {
    var downloadURL: URL? { get }
}

extension Downloadable {
    public func startDownload() {
        AEDownloadManager.shared.startDownload(with: self)
    }
    public func stopDownload() {
        AEDownloadManager.shared.stopDownload(for: self)
    }
}

open class AEDownloadManager: NSObject {

    // MARK: Singleton

    public static let shared = AEDownloadManager()

    // MARK: Properties

    public weak var delegate: AEDownloadManagerDelegate?

    private lazy var session: URLSession = {
        let identifier = "net.tadija.AEDownloadManager"
        let config = URLSessionConfiguration.background(withIdentifier: identifier)
        let session = URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue.main)
        return session
    }()

    private var tasks = [URLSessionDownloadTask]()

    public private(set) var items = [Downloadable]()

    // MARK: API / URL

    public func startDownload(with url: URL) {
        let task = session.downloadTask(with: url)
        tasks.append(task)
        task.resume()

        delegate?.didStartDownloadTask(task)
        if let item = item(with: url) {
            item.didStartDownloadTask(task)
        }
    }

    public func stopDownload(with url: URL) {
        if let task = task(with: url) {
            task.cancel()
            delegate?.didStopDownloadTask(task)
            if let item = item(with: task) {
                item.didStopDownloadTask(task)
            }
            performCleanup(for: task)
        }
    }

    // MARK: API / Downloadable

    public func startDownload(with item: Downloadable) {
        if let url = item.downloadURL {
            items.append(item)
            startDownload(with: url)
        }
    }

    public func stopDownload(for item: Downloadable) {
        if let url = item.downloadURL {
            stopDownload(with: url)
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

extension AEDownloadManager: URLSessionDelegate, URLSessionDownloadDelegate {

    // MARK: URLSessionDownloadDelegate

    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,
                           didWriteData bytesWritten: Int64,
                           totalBytesWritten: Int64,
                           totalBytesExpectedToWrite: Int64) {
        if totalBytesExpectedToWrite > 0 {
            let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
            delegate?.didUpdateDownloadTask(downloadTask, progress: progress)
            if let item = item(with: downloadTask) {
                item.didUpdateDownloadTask(downloadTask, progress: progress)
            }
        }
    }

    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,
                           didFinishDownloadingTo location: URL) {
        delegate?.didFinishDownloadTask(downloadTask, to: location)
        if let item = item(with: downloadTask) {
            item.didFinishDownloadTask(downloadTask, to: location)
        }
        performCleanup(for: downloadTask)
    }

    // MARK: URLSessionTaskDelegate

    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        delegate?.didFailDownloadTask(task, with: error)
        if let item = item(with: task) {
            item.didFailDownloadTask(task, with: error)
        }
        performCleanup(for: task)
    }

}
