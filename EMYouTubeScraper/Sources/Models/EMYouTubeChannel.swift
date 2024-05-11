//
//  EMYoutubeChannel.swift
//  EMYoutubeScraper
//
//  Created by Tam Nguyen on 24/3/24.
//

import Foundation
import EMFoundation

public struct EMYoutubeChannel {
    public var channelId: String
    public var title: EMYoutubeText?
    public var thumbnails: [EMYoutubeThumbnail] = []
    public var descriptionSnippet: EMYoutubeText?
    public var videoCountText: EMYoutubeText?
}
