//
//  EMYoutubeModelMapper.swift
//  EMYoutubeScraper
//
//  Created by Tam Nguyen on 24/3/24.
//

import Foundation
import EMFoundation

struct EMYouTubeModelMapper {
    static func mapVideo(fromDict dict: [String: Any]) throws -> EMYouTubeVideo {
        guard let videoId = dict["videoId"] as? String else {
            throw EMYouTubeScraperError.parsingDataFailed
        }

        var video = EMYouTubeVideo(videoId: videoId)
        video.title = getSubDictAndMapText(fromDict: dict, key: "title")
        video.publishedTimeText = getSubDictAndMapText(fromDict: dict, key: "publishedTimeText")
        video.viewCountText = getSubDictAndMapText(fromDict: dict, key: "viewCountText")
        video.shortViewCountText = getSubDictAndMapText(fromDict: dict, key: "shortViewCountText")
        video.lengthText = getSubDictAndMapText(fromDict: dict, key: "lengthText")
        video.ownerText = getSubDictAndMapText(fromDict: dict, key: "ownerText")
        video.videoInfo = getSubDictAndMapText(fromDict: dict, key: "videoInfo")

        if let thumbnailsDict: [[String: Any]] = dict[keyPath: "thumbnail.thumbnails"] {
            video.thumbnails = thumbnailsDict.compactMap { try? mapThumbnail(fromDict: $0) }
        }

        return video
    }

    static func mapText(fromDict dict: [String: Any]) -> EMYoutubeText {
        var text = EMYoutubeText()
        text.simpleText = dict["simpleText"] as? String

        if let runs = dict["runs"] as? [[String: Any]] {
            text.runTexts = runs.compactMap { $0["text"] as? String }
        }

        return text
    }

    static func mapThumbnail(fromDict dict: [String: Any]) throws -> EMYoutubeThumbnail {
        guard let urlString = dict["url"] as? String,
              let url = URL(string: urlString) else {
            throw EMYouTubeScraperError.parsingDataFailed
        }

        var thumbnail = EMYoutubeThumbnail(url: url)
        thumbnail.width = (dict["width"] as? Int) ?? 0
        thumbnail.height = (dict["height"] as? Int) ?? 0

        return thumbnail
    }

    static func mapChannel(fromDict dict: [String: Any]) throws -> EMYoutubeChannel {
        guard let channelId = dict["channelId"] as? String else {
            throw EMYouTubeScraperError.parsingDataFailed
        }

        var channel = EMYoutubeChannel(channelId: channelId)
        channel.title = getSubDictAndMapText(fromDict: dict, key: "title")
        channel.descriptionSnippet = getSubDictAndMapText(fromDict: dict, key: "descriptionSnippet")
        channel.videoCountText = getSubDictAndMapText(fromDict: dict, key: "videoCountText")

        if let thumbnailsDict: [[String: Any]] = dict[keyPath: "thumbnail.thumbnails"] {
            channel.thumbnails = thumbnailsDict.compactMap { try? mapThumbnail(fromDict: $0) }
        }

        return channel
    }

    static func mapPlaylist(fromDict dict: [String: Any]) throws -> EMYoutubePlaylist {
        guard let playlistId = dict[keyPath: "navigationEndpoint.watchPlaylistEndpoint.playlistId"] as? String else {
            throw EMYouTubeScraperError.parsingDataFailed
        }

        var playlist = EMYoutubePlaylist(playlistId: playlistId)
        playlist.title = getSubDictAndMapText(fromDict: dict, key: "title")
        playlist.description = getSubDictAndMapText(fromDict: dict, key: "description")
        playlist.videoCountText = getSubDictAndMapText(fromDict: dict, key: "videoCountText")

        if let thumbnailsDict: [[String: Any]] = dict[keyPath: "thumbnail.thumbnails"] {
            playlist.thumbnails = thumbnailsDict.compactMap { try? mapThumbnail(fromDict: $0) }
        }

        return playlist
    }

    static func mapVideoStreamPlayabilityStatus(fromDict dict: [String: Any]) -> EMYoutubeVideoStreamPlayabilityStatus {
        var status = EMYoutubeVideoStreamPlayabilityStatus()

        if let statusValue = dict["status"] as? String {
            status.status = .init(rawValue: statusValue) ?? .unplayable
        }

        status.reason = dict["reason"] as? String

        return status
    }

    static func mapStreamLink(fromDict dict: [String: Any]) throws -> EMYoutubeVideoStreamLink {
        guard let urlString = dict["url"] as? String, let url = URL(string: urlString) else {
            throw EMYouTubeScraperError.parsingDataFailed
        }

        var link = EMYoutubeVideoStreamLink(url: url)

        if let itagValue = dict["itag"] as? Int {
            link.itag = EMYoutubeVideoItag(rawValue: itagValue) ?? .undefined
        }

        link.mimeType = dict["mimeType"] as? String
        link.bitrate = (dict["bitrate"] as? Int) ?? 0
        link.width = dict["width"] as? Int
        link.height = dict["height"] as? Int

        if let contentLength = dict["contentLength"] as? String {
            link.fileSize = Int(contentLength)
        }

        if let qualityString = dict["quality"] as? String {
            link.quality = .init(rawValue: qualityString) ?? .none
        }

        if let audioQualityString = dict["audioQuality"] as? String {
            link.audioQuality = .init(rawValue: audioQualityString) ?? .none
        }

        link.fps = dict["fps"] as? Int
        link.qualityLabel = dict["qualityLabel"] as? String
        link.averageBitrate = (dict["averageBitrate"] as? Int) ?? 0

        if let approxDurationMsString = dict["approxDurationMs"] as? String {
            link.approxDurationMilliseconds = Int(approxDurationMsString)
        }
        
        if let sampleRateString = dict["audioSampleRate"] as? String {
            link.audioSampleRate = Int(sampleRateString) ?? 44100
        }

        link.audioChanel = (dict["audioChannels"] as? Int) ?? 2

        return link
    }

    static func mapVideoStream(fromDict dict: [String: Any]) -> EMYouTubeVideoStream {
        let playabilityDict = dict["playabilityStatus"] as? [String: Any]
        let playabilityStatus = mapVideoStreamPlayabilityStatus(fromDict: playabilityDict ?? [:])

        var videoStream = EMYouTubeVideoStream(playabilityStatus: playabilityStatus)

        // Map vide links
        var linkDicts = [[String: Any]]()
        if let formatDicts = dict[keyPath: "streamingData.formats"] as? [[String: Any]] {
            linkDicts.append(contentsOf: formatDicts)
        }
        if let adaptiveDicts = dict[keyPath: "streamingData.adaptiveFormats"] as? [[String: Any]] {
            linkDicts.append(contentsOf: adaptiveDicts)
        }
        videoStream.streamLinks = linkDicts.compactMap {
            try? mapStreamLink(fromDict: $0)
        }

        // Map other info
        if let expiresInSecondsString = dict[keyPath: "streamingData.expiresInSeconds"] as? String, let seconds = TimeInterval(expiresInSecondsString) {
            videoStream.expirationDate = Date(timeIntervalSinceNow: seconds)
        }

        videoStream.aspectRatio = dict[keyPath: "streamingData.aspectRatio"] as? Double

        return videoStream
    }

    static func mapPlaylistCollection(fromDict dict: [String: Any]) throws -> EMYouTubePlaylistCollection {
        var result = EMYouTubePlaylistCollection()
        result.title = getSubDictAndMapText(fromDict: dict, key: "title")

        let allPlaylistDicts: [[String: Any]] = dict.findAllValueRecursively(byKey: "compactStationRenderer")
        result.playlists = try allPlaylistDicts.map {
            try EMYouTubeModelMapper.mapPlaylist(fromDict: $0)
        }

        return result
    }
}

extension EMYouTubeModelMapper {
    private static func getSubDictAndMapText(fromDict dict: [String: Any], key: String) -> EMYoutubeText? {
        guard let subDict = dict[key] as? [String: Any] else {
            return nil
        }

        return mapText(fromDict: subDict)
    }
}
