//
//  UploadItem.swift
//  ChatApp
//
//  Created by Ngoc Tam Nguyen on 1/31/15.
//  Copyright (c) 2015 Ngoc Tam Nguyen. All rights reserved.
//

import Foundation

public typealias EMUploadProgressBlock =  (_ bytesSent: Int64, _ totalBytesSent: Int64, _ totalBytesExpectedToSend: Int64) -> Void
public typealias EMUploadCompletionBlock = (_ result: Result<Data, NSError>) -> Void

public class EMUploadRequestItem {

    var urlString: String
    var uploadTask: URLSessionUploadTask?
    private(set) var isCancelled = false
    private(set) var data = Data()

    // Blocks handlers
    var progressBlock: EMUploadProgressBlock?
    var completionBlock: EMUploadCompletionBlock?

    // Uploaded percent
    var uploadedPercent: CGFloat {
        guard let uploadTask = uploadTask else {
            return 0
        }

        if uploadTask.countOfBytesExpectedToSend == 0 {
            return 0
        } else {
            return CGFloat(uploadTask.countOfBytesSent) / CGFloat(uploadTask.countOfBytesExpectedToSend)
        }
    }

    init(
        urlString: String,
        progress: EMUploadProgressBlock?,
        completion: EMUploadCompletionBlock?
    ) {
        self.urlString = urlString
        progressBlock = progress
        completionBlock = completion
    }

    deinit {
        uploadTask = nil
        removeAllBlocks()
    }

    // MARK: Public methods

    func resume() {
        uploadTask?.resume()
    }

    func pause() {
        uploadTask?.suspend()
    }

    func cancel() {
        isCancelled = true

        if uploadTask != nil {
            uploadTask?.cancel()
        } else {
            finishedUpload(NSError(domain: "FileServices.UploadItem", code: -1, userInfo: nil))
        }

        uploadTask = nil
    }

    func removeAllBlocks() {
        progressBlock = nil
        completionBlock = nil
    }

    func didUploadData(_ bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        progressBlock?(bytesSent, totalBytesSent, totalBytesExpectedToSend)
    }

    func didReceivedData(data: Data) {
        self.data.append(data)
    }

    func finishedUpload(_ error: NSError?) {
        if isCancelled {
            completionBlock?(.failure(.createHttpClientCancelledError()))
        } else if let error {
            completionBlock?(.failure(error))
        } else {
            completionBlock?(.success(data))
        }

        // Remove block
        removeAllBlocks()
    }
}
