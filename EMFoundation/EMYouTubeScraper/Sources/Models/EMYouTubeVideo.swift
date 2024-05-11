//
//  EMYoutubeVideo.swift
//  EMYoutubeScraper
//
//  Created by Tam Nguyen on 23/3/24.
//

import Foundation
import EMFoundation

public struct EMYouTubeVideo {
    public var videoId: String
    public var title: EMYoutubeText?
    public var thumbnails: [EMYoutubeThumbnail] = []
    public var publishedTimeText: EMYoutubeText?
    public var viewCountText: EMYoutubeText?
    public var shortViewCountText: EMYoutubeText?
    public var lengthText: EMYoutubeText?
    public var ownerText: EMYoutubeText?
    public var videoInfo: EMYoutubeText?
}
