//
//  EMYoutubeParser.swift
//  EMYoutubeScraper
//
//  Created by Tam Nguyen on 24/3/24.
//

import Foundation
import EMFoundation

struct EMYouTubeParser {
    static func parseCollection(fromYoutubeJSData youtubeData: EMYoutubeJSData) throws -> EMYouTubeVideoCollectionResult {
        var result = EMYouTubeVideoCollectionResult()
        result.context = youtubeData.context ?? [:]

        if let contentsDict = youtubeData.initialData?["contents"] as? [String: Any] {
            let allVideoDicts: [[String: Any]] = contentsDict.findAllValueRecursively(byKey: "videoRenderer")
            result.videos = try allVideoDicts.map { try EMYouTubeModelMapper.mapVideo(fromDict: $0) }
        }

        return result
    }

    static func parsePlaylistCollections(fromYoutubeJSData youtubeData: EMYoutubeJSData) throws -> [EMYouTubePlaylistCollection] {
        var result = [EMYouTubePlaylistCollection]()

        if let contentsDict = youtubeData.initialData?["contents"] as? [String: Any] {
            let allCollectionDicts: [[String: Any]] = contentsDict.findAllValueRecursively(byKey: "shelfRenderer")

            result = try allCollectionDicts.map {
                try EMYouTubeModelMapper.mapPlaylistCollection(fromDict: $0)
            }
        }

        return result
    }

    static func parsePlaylistVideos(fromYoutubeJSData youtubeData: EMYoutubeJSData) throws -> [EMYouTubeVideo] {
        var result = [EMYouTubeVideo]()

        if let contentsDict = youtubeData.initialData?["contents"] as? [String: Any] {
            let allVideoDicts: [[String: Any]] = contentsDict.findAllValueRecursively(byKey: "playlistVideoRenderer")
            result = try allVideoDicts.map {
                try EMYouTubeModelMapper.mapVideo(fromDict: $0)
            }
        }

        return result
    }

    static func parseMixPlaylistVideos(fromYoutubeJSData youtubeData: EMYoutubeJSData) throws -> [EMYouTubeVideo] {
        var result = [EMYouTubeVideo]()

        if let contentsDict = youtubeData.initialData?["contents"] as? [String: Any] {
            let allVideoDicts: [[String: Any]] = contentsDict.findAllValueRecursively(byKey: "playlistPanelVideoRenderer")
            result = try allVideoDicts.map {
                try EMYouTubeModelMapper.mapVideo(fromDict: $0)
            }
        }

        return result
    }

    static func parseSearchResult(fromYoutubeJSData youtubeData: EMYoutubeJSData) throws -> EMYouTubeSearchResult {
        var result = EMYouTubeSearchResult()
        result.context = youtubeData.context

        if let initialData = youtubeData.initialData {
            result.estimatedResultCount = initialData["estimatedResults"] as? String

            if let contentDict = initialData["contents"] as? [String: Any] {
                let allVideoDicts: [[String: Any]] = contentDict.findAllValueRecursively(byKey: "videoRenderer")
                result.videos = try allVideoDicts.map { try EMYouTubeModelMapper.mapVideo(fromDict: $0) }

                // Parse continuation command
                if let continuationCommandDict: [String: Any] = contentDict.findAllValueRecursively(byKey: "continuationCommand").first,
                   let token = continuationCommandDict["token"] as? String {
                    result.continuation = EMYoutubeQueryContinuation(token: token)
                }
            }
        }

        return result
    }

    static func parseContinueSearchResult(context: [String: Any]?, responseJson: [String: Any]) throws -> EMYouTubeSearchResult {
        var result = EMYouTubeSearchResult()
        result.context = context
        result.estimatedResultCount = responseJson["estimatedResults"] as? String

        if let contentDict = (responseJson["onResponseReceivedCommands"] as? [[String: Any]])?.first {
            let allVideoDicts: [[String: Any]] = contentDict.findAllValueRecursively(byKey: "videoRenderer")
            result.videos = try allVideoDicts.map { try EMYouTubeModelMapper.mapVideo(fromDict: $0) }

            // Parse continuation command
            if let continuationCommandDict: [String: Any] = contentDict.findAllValueRecursively(byKey: "continuationCommand").first,
               let token = continuationCommandDict["token"] as? String {
                result.continuation = EMYoutubeQueryContinuation(token: token)
            }
        }

        return result
    }

    static func parseVideoStream(fromDict dict: [String: Any], filterItags: [EMYoutubeVideoItag]) -> EMYouTubeVideoStream {
        var stream = EMYouTubeModelMapper.mapVideoStream(fromDict: dict)

        if !filterItags.isEmpty {
            stream.streamLinks = stream.streamLinks.filter { filterItags.contains($0.itag) }
        }

        return stream
    }
}
