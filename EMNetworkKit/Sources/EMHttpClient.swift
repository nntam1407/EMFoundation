//
//  FileServices.swift
//  ChatApp
//
//  Created by Ngoc Tam Nguyen on 1/26/15.
//  Copyright (c) 2015 Ngoc Tam Nguyen. All rights reserved.
//

import Foundation
import EMFoundation

public class EMHttpClient: NSObject, EMHttpClientProtocol {
    private enum Constants {
        static let defaultDownloadFileExtension = "temp"
        static let downloadCacheDirectory = "/EMHttpClientDownload"
        static let uploadCacheDirectory = "/EMHttpClientUpload"
        static let defaultTempFileExtension = "temp"
        static let downloadSessionIdentifer = "lgHttpClient.download.session"
        static let uploadSessionIdentifer = "lgHttpClient.upload.session"
        static let restAPISessionIdentifer = "lgHttpClient.restapi.session"
    }

    public var configuration: EMHttpClientConfiguration {
        didSet {
            updateConfigurationForDownloadSession(session: downloadSession)
            updateConfigurationForUploadSession(session: uploadSession)
            updateConfigurationForRestAPISession(session: restAPISession)
        }
    }

    public var defaultDownloadRequestHeaders: [String: String] = [:]
    public var defaultUploadRequestHeaders: [String: String] = [:]
    public var defaultRestAPIRequestHeaders: [String: String] = [:]

    public var cacheDownloadFolderPath: String {
        getCacheDownloadDirectory()
    }

    private var downloadItems = EMThreadSafeDictionary<String, EMDownloadItem>() // Key is URL string
    private var uploadItems = EMThreadSafeDictionary<String, EMUploadRequestItem>()
    private var restRequestItems = EMThreadSafeDictionary<String, EMRestAPIRequestItem>()

    private var alreadySetup = false

    private lazy var downloadSession: URLSession = {
        let downloadSessionConfigs = URLSessionConfiguration.background(withIdentifier: Constants.downloadSessionIdentifer)
        let session = URLSession(configuration: downloadSessionConfigs, delegate: self, delegateQueue: nil)
        return session
    }()

    private lazy var uploadSession: URLSession = {
        let uploadSessionConfigs = URLSessionConfiguration.background(withIdentifier: Constants.uploadSessionIdentifer)
        let session = URLSession(configuration: uploadSessionConfigs, delegate: self, delegateQueue: nil)
        updateConfigurationForUploadSession(session: session)
        return session
    }()

    private lazy var restAPISession: URLSession = {
        let session = URLSession(
            configuration: .default,
            delegate: self,
            delegateQueue: nil
        )
        updateConfigurationForRestAPISession(session: session)
        return session
    }()

    private(set) var downloadBackgroundURLSessionCompletionHandler: (() -> Void)?
    private(set) var uploadBackgroundURLSessionCompletionHandler: (() -> Void)?

    // MARK: Override methods

    public init(configuration: EMHttpClientConfiguration) {
        self.configuration = configuration
        super.init()
    }

    public static let shared: EMHttpClient = {
        EMHttpClient(configuration: .default)
    }()

    // MARK: Support methods

    public func setBackgroundURLSessionCompletionHandler(handler: (() -> Void)?, sessionIdentifier: String) {
        if downloadSession.configuration.identifier == sessionIdentifier {
            downloadBackgroundURLSessionCompletionHandler = handler
        } else if uploadSession.configuration.identifier == sessionIdentifier {
            uploadBackgroundURLSessionCompletionHandler = handler
        }
    }

    private func updateConfigurationForDownloadSession(session: URLSession) {
        let configs = session.configuration
        configs.httpMaximumConnectionsPerHost = configuration.maxDownloadFiles
        configs.allowsCellularAccess = configuration.allowCellularAccess
    }

    private func updateConfigurationForUploadSession(session: URLSession) {
        let configs = session.configuration
        configs.httpMaximumConnectionsPerHost = configuration.maxUploadFiles
        configs.allowsCellularAccess = configuration.allowCellularAccess
    }

    private func updateConfigurationForRestAPISession(session: URLSession) {
        let configs = session.configuration
        configs.httpMaximumConnectionsPerHost = configuration.maxConnectionsPerHost
        configs.requestCachePolicy = configuration.requestCachePolicy
        configs.allowsCellularAccess = configuration.allowCellularAccess
        configs.timeoutIntervalForRequest = configuration.timeoutInterval
        configs.timeoutIntervalForResource = configuration.timeoutInterval
    }

    private func getCachesDirectory(subPath: String?) -> String {
        var documentDir = EMFileUtils.applicationCachesDirectory().path

        if let subPath = subPath {
            documentDir = (documentDir as NSString).appendingPathComponent(subPath)
        }

        // Try to create this folder if is not exist
        EMFileUtils.createFolderAtPath(documentDir)

        return documentDir
    }

    private func appendRequestHeader(_ request: inout URLRequest, headers: [String: String?]?) {
        if headers != nil && headers!.count > 0 {
            for (key, value) in headers! {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
    }

    private func generateRequestId() -> String {
        UUID().uuidString
    }

    private func generateMultipartDataBoundary() -> String {
        UUID().uuidString
    }

    public func clearCacheDownloadFolder() {
        do {
            try FileManager.default.removeItem(atPath: cacheDownloadFolderPath)

            // Re-create cache folder
            EMFileUtils.createFolderAtPath(cacheDownloadFolderPath)
        } catch {
            print("EMNetworkKit remove cache download folder error: \(error.localizedDescription)")
        }
    }

    /**
     Method cancel request include download task, upload task and rest API task
     */
    public func cancelRequest(requestId: String) {
        downloadItems[requestId]?.cancel()
        uploadItems[requestId]?.cancel()
        restRequestItems[requestId]?.cancel()
    }
}

extension EMHttpClient {
    // MARK: Download's methods

    private func getCacheDownloadDirectory() -> String {
        return getCachesDirectory(subPath: Constants.downloadCacheDirectory)
    }

    class func generateDownloadFileName(_ urlString: String) -> String {
        return urlString.hashMD5() + "." + Constants.defaultDownloadFileExtension
    }

    /**
     Method download file.

     - urlString: url string of file download
     - fileName: name of file will be saved in local storage after downloaded
     - headers: some headers value for request
     */
    @discardableResult
    public func downloadFile(
        urlString: String,
        tagData: String?,
        headers: [String: String?]?,
        progress: EMDownloadItem.ProgressHandler?,
        completion: EMDownloadItem.CompletionHandler?
    ) -> EMDownloadItem {
        if let downloadItem = self.downloadItems[urlString] {
            if let progress {
                downloadItem.appendProgressHandler(handler: progress)
            }

            if let completion {
                downloadItem.appendCompletionHandler(handler: completion)
            }

            return downloadItem
        }

        let downloadItem = EMDownloadItem(
            urlString: urlString,
            tagData: tagData,
            progress: progress,
            completion: completion
        )

        guard let fileURL = URL(string: urlString) else {
            downloadItem.finishedDownload(nil, error: .createHttpClientInvalidURLError())
            return downloadItem
        }

        let saveFilePath = (getCacheDownloadDirectory() as NSString).appendingPathComponent(downloadItem.downloadingFileName)
        if EMFileUtils.isFileExist(saveFilePath) {
            downloadItem.finishedDownload(saveFilePath, error: nil)
            return downloadItem
        }

        downloadItems[urlString] = downloadItem

        var request = URLRequest(url: fileURL)
        request.timeoutInterval = configuration.timeoutInterval
        appendRequestHeader(&request, headers: defaultDownloadRequestHeaders)
        appendRequestHeader(&request, headers: headers)
        downloadItem.originalRequest = request

        let downloadTask = downloadSession.downloadTask(with: request)
        downloadTask.taskDescription = tagData

        downloadItem.onResumeHandler = {
            downloadTask.resume()
        }

        downloadItem.onPauseHandler = {
            downloadTask.suspend()
        }

        downloadItem.onCancelHandler = { [weak self] in
            downloadTask.cancel()
            self?.downloadItems[urlString] = nil
        }

        // Start download
        downloadItem.resume()

        return downloadItem
    }

    @discardableResult
    public func cancelDownload(urlString: String) -> EMDownloadItem? {
        let item = downloadItems[urlString]
        item?.cancel()

        return item
    }
}

extension EMHttpClient {
    public func setup(withCompletion completion: (([EMDownloadItem]) -> Void)?) {
        guard !alreadySetup else {
            assert(false, "Already setup!")
            return
        }

        alreadySetup = true

        downloadSession.getTasksWithCompletionHandler { [weak self] _, _, downloadTasks in
            guard let self else { return }

            var result = [EMDownloadItem]()

            downloadTasks.forEach { task in
                guard let originalURLString = task.originalRequest?.url?.absoluteString else { return }
                let downloadItem = EMDownloadItem(
                    urlString: originalURLString,
                    tagData: task.taskDescription,
                    progress: nil,
                    completion: nil
                )
                downloadItem.originalRequest = task.originalRequest

                switch task.state {
                case .running:
                    downloadItem.status = .progress
                case .suspended:
                    downloadItem.status = .paused
                case .canceling:
                    downloadItem.status = .userCancelled
                default:
                    downloadItem.status = .progress
                }

                downloadItem.onResumeHandler = {
                    task.resume()
                }

                downloadItem.onPauseHandler = {
                    task.suspend()
                }

                downloadItem.onCancelHandler = { [weak self] in
                    task.cancel()
                    self?.downloadItems[originalURLString] = nil
                }

                self.downloadItems[originalURLString] = downloadItem
                result.append(downloadItem)
            }

            completion?(result)
        }
    }

    // MARK: Upload methods

    private func uploadCacheDirectory() -> String {
        return getCachesDirectory(subPath: Constants.uploadCacheDirectory)
    }

    /**
     Methods support upload file
     Upload does not support multi blocks like download

     - indentifer: for recorgnize uploading item
     */
    public func uploadFile(
        urlString: String,
        filePath: String,
        headers: [String: String?]?,
        httpMethod: EMHttpMethod,
        progress: EMUploadProgressBlock?,
        completion: EMUploadCompletionBlock?
    ) -> String {
        let requestId = generateRequestId()

        // Check if this file is not exist
        guard EMFileUtils.isFileExist(filePath) else {
            completion?(.failure(.createHttpClientFileNotFoundError()))
            return requestId
        }

        // Create URL from URLString
        guard let uploadURL = URL(string: urlString) else {
            completion?(.failure(.createHttpClientInvalidURLError()))
            return requestId
        }

        // Now we will create request data to upload
        let uploadItem = EMUploadRequestItem(urlString: urlString, progress: progress, completion: completion)

        // Create upload request
        var request = URLRequest(url: uploadURL)
        request.httpMethod = httpMethod.rawValue
        request.timeoutInterval = configuration.timeoutInterval
        appendRequestHeader(&request, headers: defaultUploadRequestHeaders)
        appendRequestHeader(&request, headers: headers)
        request.setValue("\(EMFileUtils.fileSize(filePath))", forHTTPHeaderField: "Content-Length")

        // Create upload task
        let uploadTask = uploadSession.uploadTask(with: request as URLRequest, fromFile: URL(fileURLWithPath: filePath))
        uploadTask.taskDescription = requestId
        uploadItem.uploadTask = uploadTask
        uploadItems[requestId] = uploadItem
        uploadTask.resume()

        return requestId
    }

    public func uploadMultiPartRequest(
        urlString: String,
        headers: [String: String]?,
        multipartDatas: [EMMultipartData],
        httpMethod: EMHttpMethod,
        progress: EMUploadProgressBlock?,
        completion: EMUploadCompletionBlock?
    ) -> String {
        let requestId = generateRequestId()

        guard let uploadURL = URL(string: urlString) else {
            completion?(.failure(.createHttpClientInvalidURLError()))
            return requestId
        }

        // Now we will create request data to upload
        let uploadItem = EMUploadRequestItem(urlString: urlString, progress: progress, completion: completion)

        // Create upload request
        var request = URLRequest(url: uploadURL)
        request.httpMethod = httpMethod.rawValue
        request.timeoutInterval = configuration.timeoutInterval
        appendRequestHeader(&request, headers: defaultUploadRequestHeaders)
        appendRequestHeader(&request, headers: headers)

        // Create body data
        let boundary = generateMultipartDataBoundary()
        let bodyMultipartData = NSMutableData()

        for multipartData in multipartDatas {
            bodyMultipartData.append(multipartData.toMultipartData(boundary))
        }

        // Append end of multipart data
        bodyMultipartData.append(("--\(boundary)--\r\n").data(using: String.Encoding.utf8, allowLossyConversion: true)!)

        // Init data and header fo request
        request.httpBody = bodyMultipartData as Data
        request.setValue("\(bodyMultipartData.length)", forHTTPHeaderField: "Content-Length")
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        // Create upload task
        let uploadTask = uploadSession.uploadTask(withStreamedRequest: request as URLRequest)
        uploadTask.taskDescription = requestId
        uploadItem.uploadTask = uploadTask
        uploadItems[requestId] = uploadItem
        uploadTask.resume()

        return requestId
    }

    /**
     Method get percent uploaded with identifer
     */
    public func getUploadedPercent(requestId: String) -> CGFloat {
        if let uploadItem = self.uploadItems[requestId] {
            return uploadItem.uploadedPercent
        }

        return 0.0
    }
}

extension EMHttpClient {
    // MARK: Rest API request

    public func makeRequest(
        urlString: String,
        headers: [String: String]?,
        bodyData: Data?,
        httpMethod: EMHttpMethod,
        completion: EMRestRequestCompletion?
    ) -> String {
        let requestId = generateRequestId()

        guard let requestURL = URL(string: urlString) else {
            completion?(urlString, .failure(.createHttpClientInvalidURLError()))
            return requestId
        }

        // Now we will create request data to rest request
        let restRequestItem = EMRestAPIRequestItem(urlString: urlString, completion: completion)

        // Create upload request
        var request = URLRequest(url: requestURL)
        request.httpMethod = httpMethod.rawValue
        request.httpBody = bodyData
        request.timeoutInterval = configuration.timeoutInterval
        appendRequestHeader(&request, headers: defaultRestAPIRequestHeaders)
        appendRequestHeader(&request, headers: headers)

        // Create upload task
        let dataTask = restAPISession.dataTask(with: request)
        dataTask.taskDescription = requestId
        restRequestItem.dataTask = dataTask
        restRequestItems[requestId] = restRequestItem
        dataTask.resume()

        return requestId
    }
}

extension EMHttpClient: URLSessionDataDelegate, URLSessionDownloadDelegate {
    // MARK: Session delegates

    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {

        if session == self.downloadSession, let urlString = downloadTask.originalRequest?.url?.absoluteString {
            // Get download item
            guard let downloadItem = self.downloadItems[urlString] else {
                return
            }

            let saveFilePath = (self.getCacheDownloadDirectory() as NSString).appendingPathComponent(downloadItem.downloadingFileName)

            // Move file to destination path
            if EMFileUtils.moveFile(location.path, destPath: saveFilePath) {
                downloadItem.finishedDownload(saveFilePath, error: nil)
            } else {
                downloadItem.finishedDownload(nil, error: .createHttpClientCannotMoveFileError())
            }

            // Remove download item in dictionary
            self.downloadItems[urlString] = nil
        }
    }

    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {

        print("Bytes written: \(bytesWritten), totalBytesWritten: \(totalBytesWritten), totalBytesExpectedToWrite: \(totalBytesExpectedToWrite)")

        // Get download item
        if session == self.downloadSession {
            let downloadItem = self.downloadItems[downloadTask.originalRequest!.url!.absoluteString]
            downloadItem?.didReceivedData(bytesWritten, totalBytesWritten: totalBytesWritten, totalBytesExpectedToWrite: totalBytesExpectedToWrite)
        }
    }

    public func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {

        if session == self.uploadSession {
            let uploadItem = self.uploadItems[task.taskDescription!]
            uploadItem?.didUploadData(bytesSent, totalBytesSent: totalBytesSent, totalBytesExpectedToSend: totalBytesExpectedToSend)
        }
    }

    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        if session == self.uploadSession {
            // TODO: Handle upload response from server

            guard let requestId = dataTask.taskDescription, let uploadItem = self.uploadItems[requestId] else {
                return
            }

            uploadItem.didReceivedData(data: data)

        } else if session == self.restAPISession {
            // TODO: Handle rest api response from server

            guard let requestId = dataTask.taskDescription, let restRequestItem = self.restRequestItems[requestId] else {
                return
            }

            restRequestItem.didReceivedData(data: data)
        }
    }

    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {

        // Handle download complete and failed
        if session == self.downloadSession && error != nil {

            // Get download item
            let downloadItem = self.downloadItems[task.originalRequest!.url!.absoluteString]

            if downloadItem != nil {
                downloadItem!.finishedDownload(nil, error: error as NSError?)

                // Remove download item in dictionary
                self.downloadItems[task.originalRequest!.url!.absoluteString] = nil
            }

        } else if session == self.uploadSession {
            // TODO: Hanlde upload task completed
            // Try to get upload items
            let uploadItem = self.uploadItems[task.taskDescription!]

            if uploadItem != nil {
                uploadItem!.finishedUpload(error as NSError?)

                // remove upload item in dictionary
                self.uploadItems[task.taskDescription!] = nil
            }
        } else if session == self.restAPISession {
            // Handle delegate for rest api request
            let restRequestItem = self.restRequestItems[task.taskDescription!]

            if restRequestItem != nil {
                restRequestItem!.finishedRequest(error as NSError?)

                // remove upload item in dictionary
                self.restRequestItems[task.taskDescription!] = nil
            }
        }
    }

    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {

    }

    public func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        if session == downloadSession {
            downloadBackgroundURLSessionCompletionHandler?()
            downloadBackgroundURLSessionCompletionHandler = nil
        } else if session == uploadSession {
            uploadBackgroundURLSessionCompletionHandler?()
            uploadBackgroundURLSessionCompletionHandler = nil
        }
    }

    public func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        DLog("URLSession error: %@", error.debugDescription)
    }
}
