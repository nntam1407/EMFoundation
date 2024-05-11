//
//  PHAssetUtils.swift
//  MySpace
//
//  Created by Nguyen Ngoc Tam on 26/5/20.
//  Copyright © 2020 Logi. All rights reserved.
//
#if canImport(UIKit)

import Foundation
import Photos
import UIKit
import EMFoundation

public class EMPHAssetUtils {
    class func exportMaxSizeImage(asset: PHAsset, completion: @escaping (_ image: UIImage?) -> Void) -> PHImageRequestID? {
        guard asset.mediaType == .image else {
            completion(nil)
            return nil
        }

        let imageManager = PHImageManager.default()

        let options = PHImageRequestOptions()
        options.resizeMode = .exact
        options.deliveryMode = .highQualityFormat
        options.isSynchronous = true
        options.isNetworkAccessAllowed = true

        let requestID = imageManager.requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .default, options: options) { (image, info) in
            if let info = info, let isDegraded = info[PHImageResultIsDegradedKey] as? Bool, isDegraded {
                return
            }

            DispatchQueue.main.async {
                completion(image)
            }
        }

        return requestID
    }

    class func exportBestQualityImage(asset: PHAsset, toFile filePath: String, completion: @escaping (_ filePath: String, _ succeed: Bool, _ error: NSError?) -> Void) -> PHImageRequestID? {

        // Declare final block
        let finalBlock: (Bool, NSError?) -> Void = { (succeed, error) in
            DispatchQueue.main.async {
                completion(filePath, succeed, error)
            }
        }

        let requestID = exportMaxSizeImage(asset: asset) { (image) in
            guard let image = image else {
                finalBlock(false, nil)
                return
            }

            DispatchQueue.global(qos: .background).async {
                guard let data = image.jpegData(compressionQuality: 1.0) else {
                    finalBlock(false, nil)
                    return
                }

                do {
                    try data.write(to: URL(fileURLWithPath: filePath))
                    finalBlock(true, nil)
                } catch let error as NSError {
                    DLog("Export image asset to file to path: [%@]\nerror: %@", filePath, error.localizedDescription)
                    finalBlock(false, error)
                }
            }
        }

        return requestID
    }

    class func exportBestQualityVideo(
        asset: PHAsset,
        toFile filePath: String,
        beginExporting: @escaping (_ exportSession: AVAssetExportSession) -> Void,
        completion: @escaping (_ filePath: String, _ succeed: Bool, _ error: NSError?) -> Void
    ) -> PHImageRequestID? {

        guard asset.mediaType == .video else {
            completion(filePath, false, nil)
            return nil
        }

        // Declare final block
        let finalBlock: (Bool, NSError?) -> Void = { (succeed, error) in
            DispatchQueue.main.async {
                completion(filePath, succeed, error)
            }
        }

        let assetMaanager = PHImageManager.default()

        let options = PHVideoRequestOptions()
        options.isNetworkAccessAllowed = true
        options.deliveryMode = .highQualityFormat

        let requestID = assetMaanager.requestExportSession(forVideo: asset, options: options, exportPreset: AVAssetExportPresetHighestQuality) { (assetExportSession, info) in
            guard let assetExportSession = assetExportSession else {
                let error = info?[PHImageErrorKey] as? NSError
                finalBlock(false, error)
                return
            }

            assetExportSession.outputFileType = .mp4
            assetExportSession.outputURL = URL(fileURLWithPath: filePath)

            // Call block begin exporting
            beginExporting(assetExportSession)

            // Start export
            assetExportSession.exportAsynchronously {
                guard assetExportSession.status == .completed else {
                    let error = assetExportSession.error as NSError?
                    finalBlock(false, error)
                    return
                }

                finalBlock(true, nil)
            }
        }

        return requestID
    }

    class func originalFileName(asset: PHAsset) -> String? {
        let resource = PHAssetResource.assetResources(for: asset)
        return resource.first?.originalFilename
    }

    class func requestThumbnailImage(forAsset asset: PHAsset, targetSize: CGSize, contentMode: PHImageContentMode, completion: @escaping (_ image: UIImage?) -> Void) {
        let imageManager = PHCachingImageManager.default()

        let options = PHImageRequestOptions()
        options.deliveryMode = PHImageRequestOptionsDeliveryMode.highQualityFormat
        options.isSynchronous = false
        options.isNetworkAccessAllowed = true

        imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: contentMode, options: options) { (image, _) in
            completion(image)
        }
    }
}

#endif
