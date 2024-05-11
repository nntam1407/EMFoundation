//
//  EMYoutubeSearchResult.swift
//  EMYoutubeScraper
//
//  Created by Tam Nguyen on 24/3/24.
//

import Foundation
import EMFoundation

public struct EMYouTubeSearchResult: EMYoutubeResult {
    public var context: [String : Any]?
    public var videos = [EMYouTubeVideo]()
    public var estimatedResultCount: String?
    public var continuation: EMYoutubeQueryContinuation?
}
