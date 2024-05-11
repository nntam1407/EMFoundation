//
//  EMYoutubeJSData.swift
//  EMYoutubeScraper
//
//  Created by Tam Nguyen on 26/3/24.
//

import Foundation

struct EMYoutubeJSData {
    var config: [String: Any]?
    var initialData: [String: Any]?

    var context: [String: Any]? {
        config?[keyPath: "data_.INNERTUBE_CONTEXT"] as? [String: Any]
    }

    var apiKey: String? {
        config?[keyPath: "data_.INNERTUBE_API_KEY"] as? String
    }
}
