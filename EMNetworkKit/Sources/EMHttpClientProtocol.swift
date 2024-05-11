//
//  HttpClientProtocol.swift
//  MySpace
//
//  Created by Nguyen Ngoc Tam on 21/4/20.
//  Copyright © 2020 Logi. All rights reserved.
//

import Foundation

// Define error code
public let EMHttpClientErrorDomain = "EMNetworkKit.error"

public enum EMHttpClientErrorCode: Int {
    case existing = -10000
    case other = -9999
    case cancelled = -9998
    case fileNotFound = -9997
    case invalidURL = -9996
    case cannotMoveFile = -9995
}

public enum EMHttpMethod: String {
    case GET
    case POST
    case PUT
    case PATCH
    case DELETE
    case HEAD
}

public struct EMHttpClientConfiguration {
    enum Contants {
        static let defaultTimeout: TimeInterval = 180
        static let defaultConnectionsPerHost = 10
        static let defaultMaxDownloadFiles = 5
        static let defaultMaxUploadFiles = 1
    }

    public var timeoutInterval: TimeInterval
    public var imageProcessingQueue: DispatchQueue
    public var allowCellularAccess: Bool = true
    public var requestCachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy
    public var maxConnectionsPerHost: Int = Contants.defaultConnectionsPerHost // For rest apis
    public var maxDownloadFiles: Int = Contants.defaultMaxDownloadFiles
    public var maxUploadFiles: Int = Contants.defaultMaxUploadFiles

    public static var `default`: EMHttpClientConfiguration {
        EMHttpClientConfiguration(
            timeoutInterval: Contants.defaultTimeout,
            imageProcessingQueue: DispatchQueue(
                label: "lgHttpClient.imageProcessingQueue.shared",
                qos: .background,
                attributes: .concurrent
            )
        )
    }
}

public protocol EMHttpClientProtocol: AnyObject {

    var configuration: EMHttpClientConfiguration { get set }

    var defaultDownloadRequestHeaders: [String: String] { get set }
    var defaultUploadRequestHeaders: [String: String] { get set }
    var defaultRestAPIRequestHeaders: [String: String] { get set }

    var cacheDownloadFolderPath: String { get }

    func setup(withCompletion completion: ((_ backgroundDownloadItems: [EMDownloadItem]) -> Void)?)

    func clearCacheDownloadFolder()

    /**
     Method download file.

     - Parameters:
     - urlString: url string of file download
     - headers: customized headers
     - progress: Uploading progress. Note this closure can be invorked in background thread. You should dispatch to main queue to update UI
     - completion: Completion handler, note this closure can be invorked in background thread. You should dispatch to main queue to update UI
     */
    @discardableResult
    func downloadFile(urlString: String,
                      tagData: String?,
                      headers: [String: String?]?,
                      progress: EMDownloadItem.ProgressHandler?,
                      completion: EMDownloadItem.CompletionHandler?) -> EMDownloadItem

    /// Methods support upload file. Upload does not support multi blocks like download
    /// - Parameters:
    ///   - urlString: full url string, including host
    ///   - filePath: path to the source file on disk
    ///   - headers: customized headers
    ///   - httpMethod: GET, POST, PUT...
    ///   - progress: Uploading progress. Note this closure can be invorked in background thread. You should dispatch to main queue to update UI
    ///   - completion: Completion handler, note this closure can be invorked in background thread. You should dispatch to main queue to update UI
    /// - Returns: The requst ID, can use this to cancel the request implicitly
    @discardableResult
    func uploadFile(urlString: String,
                    filePath: String,
                    headers: [String: String?]?,
                    httpMethod: EMHttpMethod,
                    progress: EMUploadProgressBlock?,
                    completion: EMUploadCompletionBlock?) -> String

    /// Method to update file with multipart protocol
    /// - Parameters:
    ///   - urlString: full url string, including host
    ///   - headers: customized headers
    ///   - multipartDatas: Data you want to upload
    ///   - httpMethod: GET, POST, PUT...
    ///   - progress: Uploading progress. Note this closure can be invorked in background thread. You should dispatch to main queue to update UI
    ///   - completion: Completion handler, note this closure can be invorked in background thread. You should dispatch to main queue to update UI
    /// - Returns: The requst ID, can use this to cancel the request implicitly
    @discardableResult
    func uploadMultiPartRequest(urlString: String,
                                headers: [String: String]?,
                                multipartDatas: [EMMultipartData],
                                httpMethod: EMHttpMethod,
                                progress: EMUploadProgressBlock?,
                                completion: EMUploadCompletionBlock?) -> String

    /// Method to call Restful API
    /// - Parameters:
    ///   - urlString: full url string, including host
    ///   - headers: customized headers
    ///   - bodyData: request body data
    ///   - httpMethod: GET, POST, PUT...
    ///   - completion: Completion handler, note this closure can be invorked in background thread. You should dispatch to main queue to update UI
    /// - Returns: The requst ID, can use this to cancel the request implicitly
    @discardableResult
    func makeRequest(urlString: String,
                     headers: [String: String]?,
                     bodyData: Data?,
                     httpMethod: EMHttpMethod,
                     completion: EMRestRequestCompletion?) -> String

    /// Method cancel request include download task, upload task and rest API task
    /// - Parameter identifier: request identity
    func cancelRequest(requestId: String)

    @discardableResult
    func cancelDownload(urlString: String) -> EMDownloadItem?
}
