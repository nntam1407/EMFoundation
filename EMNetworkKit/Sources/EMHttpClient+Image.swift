//
//  NetworkServices+Image.swift
//  YoutubeForKids
//
//  Created by Nguyen Ngoc Tam on 29/2/20.
//  Copyright © 2020 Logi. All rights reserved.
//

import Foundation

public protocol EMHttpClientImageProtocol {
    func downloadImage(urlString: String,
                       progress: EMDownloadItem.ProgressHandler?,
                       completion: @escaping (_ urlString: String, _ result: Result<PlatformImage, NSError>) -> Void)

    func downloadImage(urlString: String, progress: EMDownloadItem.ProgressHandler?) async throws -> PlatformImage

    func downloadImage(urlString: String) async throws -> PlatformImage
}

extension EMHttpClientImageProtocol {
    public func downloadImage(urlString: String) async throws -> PlatformImage {
        try await downloadImage(urlString: urlString, progress: nil)
    }
}

extension EMHttpClient: EMHttpClientImageProtocol {
    public func downloadImage(urlString: String,
                              progress: EMDownloadItem.ProgressHandler?,
                       completion: @escaping (_ urlString: String, _ result: Result<PlatformImage, NSError>) -> Void) {
        // First try to get image from cache
        let cacheKey = EMHttpClient.generateDownloadFileName(urlString)

        if let cacheImage = EMHttpClientMemCache.shared.getCacheImage(cacheKey) {
            completion(urlString, .success(cacheImage))
            return
        }

        // Create weak self to use in blocks
        // Try to download this image
        downloadFile(
            urlString: urlString,
            tagData: nil,
            headers: nil,
            progress: progress
        ) { [weak self] url, result in
            guard let self = self else { return }

            switch result {
            case .success(let savedFilePath):
                self.configuration.imageProcessingQueue.async {
                    if let image = PlatformImage(contentsOfFile: savedFilePath) {
                        EMHttpClientMemCache.shared.cacheImage(image, forKey: cacheKey)
                        completion(url, .success(image))
                    } else {
                        completion(url, .failure(NSError(domain: NSURLErrorDomain, code: NSURLErrorUnknown, userInfo: nil)))
                    }
                }
            case .failure(let error):
                completion(url, .failure(error))
            }
        }
    }

    public func downloadImage(urlString: String, progress: EMDownloadItem.ProgressHandler?) async throws -> PlatformImage {
        try await withCheckedThrowingContinuation { [weak self] (continuation: CheckedContinuation<PlatformImage, Error>) in
            guard let self else {
                continuation.resume(throwing: NSError(domain: NSURLErrorDomain, code: NSURLErrorUnknown, userInfo: nil))
                return
            }

            downloadImage(urlString: urlString, progress: progress) { urlString, result in
                switch result {
                case .success(let image):
                    continuation.resume(returning: image)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
