//
//  EMYoutubeResult.swift
//  EMYoutubeScraper
//
//  Created by Tam Nguyen on 27/3/24.
//

import Foundation

public protocol EMYoutubeResult {
    var context: [String: Any]? { get set }
}

public extension EMYoutubeResult {
    var contextJSONString: String? {
        context?.toJsonString()
    }
}
