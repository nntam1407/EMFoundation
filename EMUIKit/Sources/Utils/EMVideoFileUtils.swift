//
//  VideoFileUtils.swift
//  MySpace
//
//  Created by Nguyen Ngoc Tam on 26/5/20.
//  Copyright © 2020 Logi. All rights reserved.
//
#if canImport(UIKit)

import Foundation
import UIKit
import AVFoundation
import EMFoundation

public class EMVideoFileUtils {
    public class func generateThumbnail(forVideoFile filePath: String) -> UIImage? {
        let fileURL = URL(fileURLWithPath: filePath)
        let asset = AVURLAsset(url: fileURL, options: nil)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true

        do {
            let cgImage = try imageGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
            return UIImage(cgImage: cgImage)
        } catch {
            DLog("Generate thumbnail for video error: %d", error.localizedDescription)
        }

        return nil
    }

    public class func generateThumbnail(forVideoFile filePath: String, maxSize: CGFloat) -> UIImage? {
        guard let image = generateThumbnail(forVideoFile: filePath) else {
            return nil
        }

        let resizedImage = image.resizedImageToFitInSize(CGSize(width: maxSize, height: maxSize), scaleIfSmaller: false)

        return resizedImage
    }

    public class func fetchMetadata(forVideoFile filePath: String) -> [String: Any]? {
        let fileURL = URL(fileURLWithPath: filePath)
        let asset = AVURLAsset(url: fileURL, options: nil)

        guard asset.isReadable else {
            return nil
        }

        var result = [String: Any]()
        result["duration"] = asset.duration.seconds

        if let track = asset.tracks(withMediaType: .video).first {
            let size = track.naturalSize.applying(track.preferredTransform)
            result["width"] = abs(size.width)
            result["height"] = abs(size.height)
        }

        return result
    }
}

#endif
