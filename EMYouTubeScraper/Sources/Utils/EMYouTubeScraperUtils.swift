//
//  EMYoutubeScraperUtils.swift
//  EMYoutubeScraper
//
//  Created by Tam Nguyen on 30/3/24.
//

import Foundation

public struct EMYoutubeScraperUtils {
     // Default will return largest
    public static func bestFitThumbnail(
        thumbnails: [EMYoutubeThumbnail],
        forSize size: CGSize,
        scale: Double = 1.0
    ) -> EMYoutubeThumbnail? {
        let checkSize = CGSize(width: size.width * scale, height: size.height * scale)

        for thumbnail in thumbnails {
            if Double(thumbnail.width) >= checkSize.width || Double(thumbnail.height) >= checkSize.height {
                return thumbnail
            }
        }

        return thumbnails.last
    }
}
