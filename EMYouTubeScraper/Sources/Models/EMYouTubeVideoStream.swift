//
//  EMYoutubeVideoStream.swift
//  EMYoutubeScraper
//
//  Created by Tam Nguyen on 27/3/24.
//

import Foundation

public struct EMYoutubeVideoStreamPlayabilityStatus {
    public enum Status: String {
        case unplayable = "UNPLAYABLE"
        case loginRequired = "LOGIN_REQUIRED"
        case ok = "OK"
    }

    public var status: Status = .unplayable
    public var reason: String?

    public var playable: Bool {
        status == .ok
    }
}

// List: https://gist.github.com/MartinEesmaa/2f4b261cb90a47e9c41ba115a011a4aa
public enum EMYoutubeVideoItag: Int, CaseIterable {
    case undefined = -1
    case video_h264_144p = 160
    case video_h264_240p = 133
    case video_h264_360p = 134
    case video_h264_480p = 135
    case video_h264_720p = 136
    case video_h264_1080p = 137
    case video_h264_1080p_2 = 216
    case video_h264_1440p = 264
    case video_h264_2160p = 266
    case video_h264_360p_legacy = 18
    case video_h264_480p_legacy = 59
    case video_h264_720p_legacy = 22
    case video_h264_1080p_legacy = 37
    case audio_acc_48kb = 139
    case audio_acc_128kb = 140
    case audio_acc_256kb = 141
}

public struct EMYoutubeVideoStreamLink {
    public enum Quality: String {
        case none
        case tiny
        case small
        case medium
        case large
        case hd720
        case hd1080
        case hd1440
        case hd2160
        case hd2880
        case highres
    }

    public enum AudioQuality: String {
        case none = "none"
        case ultraLow = "AUDIO_QUALITY_ULTRALOW"
        case low = "AUDIO_QUALITY_LOW"
        case medium = "AUDIO_QUALITY_MEDIUM"
        case high = "AUDIO_QUALITY_HIGH"
    }

    public enum FileType {
        case video
        case audio
    }

    public var itag: EMYoutubeVideoItag = .undefined
    public var url: URL
    public var mimeType: String?
    public var bitrate: Int = 0
    public var width: Int?
    public var height: Int?
    public var fileSize: Int?
    public var quality: Quality = .none
    public var audioQuality: AudioQuality = .none
    public var fps: Int?
    public var qualityLabel: String?
    public var averageBitrate: Int = 0
    public var approxDurationMilliseconds: Int?
    public var audioSampleRate: Int = 44100
    public var audioChanel: Int = 2

    public var fileType: FileType {
        if let mimeType, mimeType.hasPrefix("audio/") {
            return .audio
        }

        return .video
    }
}

public struct EMYouTubeVideoStream {
    public var playabilityStatus: EMYoutubeVideoStreamPlayabilityStatus
    public var expirationDate: Date?
    public var streamLinks: [EMYoutubeVideoStreamLink] = []
    public var aspectRatio: Double?
    public var requestUserAgent: String?

    public var isExpired: Bool {
        guard let expirationDate else {
            return false
        }

        return Date().compare(expirationDate) == .orderedDescending
    }
}
