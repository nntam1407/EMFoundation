//
//  EMYoutubeText.swift
//  EMYoutubeScraper
//
//  Created by Tam Nguyen on 24/3/24.
//

import Foundation

public struct EMYoutubeText {
    public var simpleText: String?
    public var runTexts: [String] = []

    public var fullRunText: String? {
        runTexts.combineStrings(sepatateString: " ")
    }

    public var displayedText: String? {
        simpleText ?? fullRunText
    }
}
