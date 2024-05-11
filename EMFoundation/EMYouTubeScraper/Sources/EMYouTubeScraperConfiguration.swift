//
//  EMYoutubeScraperConfiguration.swift
//  EMYoutubeScraper
//
//  Created by Tam Nguyen on 26/3/24.
//

import Foundation

public struct EMYouTubeScraperConfiguration {

    public var userAgent: String? = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.169 Safari/537.36"

    public var restAPIContentType: String = "application/json"

    public var apiKey: String = "AIzaSyAO_FJ2SlqU8Q4STEHLGCilw_Y9_11qcW8"

    public var youtubePlayerConfigs = [
        [
            "client": [
                "clientName": "ANDROID_MUSIC",
                "clientVersion": "5.26.1",
                "androidSdkVersion": 30
            ],
            "apiKey": "AIzaSyAOghZGza2MQSZkY_zfZ370N-PUdXEo8AI",
            "userAgent": "com.google.android.youtube/17.10.35 (Linux; U; Android 12; GB) gzip"
        ],
        [
            "client": [
                "clientName": "ANDROID_EMBEDDED_PLAYER",
                "clientVersion": "17.36.4",
                "androidSdkVersion": 30
            ],
            "apiKey": "AIzaSyCjc_pVEDi4qsv5MtC2dMXzpIaDoRFLsxw",
            "userAgent": "com.google.android.youtube/17.10.35 (Linux; U; Android 12; GB) gzip"
        ]
    ]

    public var supportedVideoItags = EMYoutubeVideoItag.allCases.filter { $0 != .undefined }

    public static let `default`: Self = EMYouTubeScraperConfiguration()

    mutating func updateAPIKey(apiKey: String) {
        guard self.apiKey != apiKey else { return }
        self.apiKey = apiKey
    }
}
