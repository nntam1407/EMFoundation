//
//  EMYoutubePlaylist.swift
//  EMYoutubeScraper
//
//  Created by Tam Nguyen on 24/3/24.
//

import Foundation
import EMFoundation

public struct EMYoutubePlaylist {
    public var playlistId: String
    public var title: EMYoutubeText?
    public var thumbnails: [EMYoutubeThumbnail] = []
    public var description: EMYoutubeText?
    public var videoCountText: EMYoutubeText?

    public var videos: [EMYouTubeVideo] = []
}
