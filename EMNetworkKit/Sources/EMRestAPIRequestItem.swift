//
//  RestAPIRequestItem.swift
//  AskApp
//
//  Created by Tam Nguyen on 7/11/15.
//  Copyright © 2015 Tam Nguyen. All rights reserved.
//

import Foundation

public typealias EMRestRequestCompletion = (_ url: String, _ result: Result<Data, NSError>) -> Void

public class EMRestAPIRequestItem {
    private(set) var urlString: String
    var dataTask: URLSessionDataTask?
    private(set) var isCancelled = false
    private(set) var data = Data()

    // Blocks handlers
    var completion: EMRestRequestCompletion?

    // MARK: Override methods

    init(urlString: String, completion: EMRestRequestCompletion?) {
        self.urlString = urlString
        self.completion = completion
    }

    deinit {
        dataTask = nil
        removeAllBlocks()
    }

    // MARK: Public methods

    func resume() {
        self.dataTask?.resume()
    }

    func pause() {
        self.dataTask?.suspend()
    }

    func cancel() {
        isCancelled = true

        if let dataTask {
            dataTask.cancel()
        } else {
            finishedRequest(NSError(domain: "FileServices.RestAPIRequestItem", code: -1, userInfo: nil))
        }

        dataTask = nil
    }

    func removeAllBlocks() {
        completion = nil
    }

    func didReceivedData(data: Data) {
        self.data.append(data)
    }

    func finishedRequest(_ error: NSError?) {
        if isCancelled {
            completion?(urlString, .failure(.createHttpClientCancelledError()))
        } else if let error {
            completion?(urlString, .failure(error))
        } else {
            completion?(urlString, .success(data))
        }

        removeAllBlocks()
    }
}
