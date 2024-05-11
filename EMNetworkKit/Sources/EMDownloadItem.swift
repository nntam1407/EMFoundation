//
//  DownloadItem.swift
//  ChatApp
//
//  Created by Ngoc Tam Nguyen on 1/31/15.
//  Copyright (c) 2015 Ngoc Tam Nguyen. All rights reserved.
//

import Foundation

public class EMDownloadItem {

    public typealias ProgressHandler =  (_ url: String, _ bytesWritten: Int64, _ totalBytesWritten: Int64, _ totalBytesExpectedToWrite: Int64) -> Void
    public typealias CompletionHandler = (_ url: String, _ result: Result<String, NSError>) -> Void

    public enum Status {
        case pending
        case progress
        case paused
        case completed(_ savedFilePath: String)
        case error(_ error: NSError)
        case userCancelled
    }

    public var downloadingFileName: String
    public var urlString: String
    public var tagData: String?
    public var status: Status = .pending

    public var totalBytesWritten: Int64?
    public var totalBytesExpectedToWrite: Int64?

    public var progressHandlers = [ProgressHandler]()
    public var completionHandlers = [CompletionHandler]()

    public var originalRequest: URLRequest?

    var onResumeHandler: (() -> Void)?
    var onPauseHandler: (() -> Void)?
    var onCancelHandler: (() -> Void)?

    // MARK: Override methods

    public init(
        urlString: String,
        tagData: String? = nil,
        progress: ProgressHandler?,
        completion: CompletionHandler?
    ) {
        self.urlString = urlString
        self.tagData = tagData
        downloadingFileName = EMHttpClient.generateDownloadFileName(urlString)

        if let progress {
            appendProgressHandler(handler: progress)
        }

        if let completion {
            appendCompletionHandler(handler: completion)
        }
    }

    // MARK: Public methods

    public func appendProgressHandler(handler: @escaping ProgressHandler) {
        progressHandlers.append(handler)
    }

    public func appendCompletionHandler(handler: @escaping CompletionHandler) {
        completionHandlers.append(handler)
    }

    public func resume() {
        status = .progress
        onResumeHandler?()
    }

    public func pause() {
        status = .paused
        onPauseHandler?()
    }

    public func cancel() {
        status = .userCancelled
        onCancelHandler?()
    }
}

extension EMDownloadItem {
    func didReceivedData(_ bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        self.totalBytesExpectedToWrite = totalBytesExpectedToWrite
        self.totalBytesWritten = totalBytesWritten

        progressHandlers.forEach { block in
            block(urlString, bytesWritten, totalBytesWritten, totalBytesExpectedToWrite)
        }
    }

    func finishedDownload(_ saveFilePath: String?, error: NSError?) {
        if let error {
            status = .error(error)
            completionHandlers.forEach { completion in
                completion(urlString, .failure(error))
            }
        } else if let saveFilePath {
            status = .completed(saveFilePath)
            completionHandlers.forEach { completion in
                completion(urlString, .success(saveFilePath))
            }
        } else if case .userCancelled = status {
            completionHandlers.forEach { completion in
                completion(urlString, .failure(.createHttpClientCancelledError()))
            }
        } else {
            completionHandlers.forEach { completion in
                completion(urlString, .failure(.createHttpClientOtherError()))
            }
        }

        // Remove all handlers
        progressHandlers.removeAll()
        completionHandlers.removeAll()
    }
}
