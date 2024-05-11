//
//  EMYoutubeScraper.swift
//  EMYoutubeScraper
//
//  Created by Tam Nguyen on 23/3/24.
//

import Foundation
import EMFoundation
import SwiftSoup
import JavaScriptCore

public enum EMYouTubeScraperError: Error {
    case invalidRequest
    case parsingDataFailed
    case internalError
    case externalServiceError(error: Error?)
}

public protocol EMYouTubeScraperProtocol {
    func getTrendingMusicVideoCollection() async throws -> EMYouTubeVideoCollectionResult

    func getTopHitMusicPlaylistCollections() async throws -> [EMYouTubePlaylistCollection]

    func getPlaylistVideos(playlistId: String) async throws -> [EMYouTubeVideo]

    func searchVideos(keyword: String) async throws -> EMYouTubeSearchResult

    func continueSearchVideos(continuationToken: String, context: [String: Any]?) async throws -> EMYouTubeSearchResult

    func getMixPlaylistVideos(forPlayingVideo videoId: String) async throws -> [EMYouTubeVideo]

    func getVideoStream(videoId: String) async throws -> EMYouTubeVideoStream
}

public class EMYouTubeScraper: NSObject {
    enum Constants {
        static let youtubeHost = "https://www.youtube.com"
        static let trendingMusicURLPath = "/feed/trending?bp=4gINGgt5dG1hX2NoYXJ0cw%3D%3D"
        static let topHitMusicPlaylistsURLPath = "/channel/UC-9-kyTW8ZkZNDHQJ6FgpwQ"
        static let playlistVideosPath = "/playlist"
        static let searchPath = "/results"
        static let continueSearchAPIPath = "/youtubei/v1/search"
        static let playerAPIPath = "/youtubei/v1/player"
        static let watchVideoPath = "/watch"
    }

    public enum HTTPMethod: String {
        case GET
        case POST
    }

    private(set) var config: EMYouTubeScraperConfiguration = .default

    private lazy var urlSession: URLSession = {
        let configuration = URLSessionConfiguration.default
        let session = URLSession(
            configuration: configuration,
            delegate: self,
            delegateQueue: nil
        )

        return session
    }()

    public static let shared = EMYouTubeScraper()

    public func configs(config: EMYouTubeScraperConfiguration) {
        self.config = config
    }
}

extension EMYouTubeScraper {
    private func createHTMLRequest(
        path: String,
        queryParams: [String: String]? = nil
    ) -> URLRequest? {
        var fullURLString = Constants.youtubeHost.appendPathComponent(pathComponenent: path)

        if let queryParams {
            fullURLString = fullURLString.appendQueryParams(queryParams: queryParams)
        }

        guard let url = URL(string: fullURLString) else {
            return nil
        }

        var request = URLRequest(url: url)

        if let userAgent = config.userAgent {
            request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        }

        return request
    }

    private func createRestAPIRequest(
        path: String,
        method: HTTPMethod = .GET,
        queryParams: [String: String]? = nil,
        headers: [String: String]? = nil,
        bodyJson: [String: Any]? = nil
    ) -> URLRequest? {
        var fullURLString = Constants.youtubeHost.appendPathComponent(pathComponenent: path)

        if let queryParams {
            fullURLString = fullURLString.appendQueryParams(queryParams: queryParams)
        }

        guard let url = URL(string: fullURLString) else {
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.httpBody = bodyJson?.toJsonData()

        if let userAgent = config.userAgent {
            request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        }

        request.setValue(config.restAPIContentType, forHTTPHeaderField: "Content-Type")

        headers?.forEach({ (key, value) in
            request.setValue(value, forHTTPHeaderField: key)
        })

        return request
    }

    private func isSuccessResponse(response: URLResponse) -> Bool {
        let responseStatusCode = (response as? HTTPURLResponse)?.statusCode ?? 0

        return responseStatusCode == 200 || responseStatusCode == 201
    }

    private func getHTMLDocument(for request: URLRequest) async throws -> Document {
        do {
            let (data, response) = try await urlSession.data(for: request)

            guard isSuccessResponse(response: response) else {
                throw EMYouTubeScraperError.externalServiceError(error: nil)
            }

            guard let htmlString = String(data: data, encoding: .utf8) else {
                throw EMYouTubeScraperError.parsingDataFailed
            }

            return try SwiftSoup.parse(htmlString)
        }
        catch is SwiftSoup.Exception {
            throw EMYouTubeScraperError.parsingDataFailed
        }
        catch let scraperError as EMYouTubeScraperError {
            throw scraperError
        }
        catch {
            throw EMYouTubeScraperError.externalServiceError(error: error)
        }
    }

    private func getJsonObject(for request: URLRequest) async throws -> [String: Any] {
        do {
            let (data, response) = try await urlSession.data(for: request)

            guard isSuccessResponse(response: response) else {
                throw EMYouTubeScraperError.externalServiceError(error: nil)
            }

            guard let jsonString = String(data: data, encoding: .utf8) else {
                throw EMYouTubeScraperError.parsingDataFailed
            }

            guard let jsonObject = jsonString.toJsonObject() as? [String: Any] else {
                throw EMYouTubeScraperError.parsingDataFailed
            }

            return jsonObject
        }
        catch is SwiftSoup.Exception {
            throw EMYouTubeScraperError.parsingDataFailed
        }
        catch let scraperError as EMYouTubeScraperError {
            throw scraperError
        }
        catch {
            throw EMYouTubeScraperError.externalServiceError(error: error)
        }
    }

    private func extractYoutubeJSData(fromHTMLDocument  htmlDocument: Document) -> EMYoutubeJSData {
        var result = EMYoutubeJSData()

        let context = JSContext()
        context?.exceptionHandler = { context, exception in
            DLog("Evaluate JS Error: %@", exception?.toString() ?? "")
        }

        context?.evaluateScript(
            """
                var window = this;
                var document = window.document = {};
                document.body = {};
                window.addEventListener = function() {};
            """
        )

        guard let allScripts = try? htmlDocument.getElementsByTag("script") else {
            return result
        }

        allScripts.forEach { script in
            let code = script.data()
            if !code.isEmpty {
                context?.evaluateScript(code)
            }
        }

        let configJson = context?.evaluateScript("JSON.stringify(ytcfg);")?.toString().toJsonObject()
        let initialDataJson = context?.evaluateScript("JSON.stringify(ytInitialData);")?.toString().toJsonObject()

        result.config = configJson as? [String: Any]
        result.initialData = initialDataJson as? [String: Any]


        // Try stote new api key if any
        if let apiKey = result.apiKey {
            config.updateAPIKey(apiKey: apiKey)
        }

        return result
    }
}

extension EMYouTubeScraper: EMYouTubeScraperProtocol {
    public func getTrendingMusicVideoCollection() async throws -> EMYouTubeVideoCollectionResult {
        guard let request = createHTMLRequest(path: Constants.trendingMusicURLPath) else {
            throw EMYouTubeScraperError.invalidRequest
        }

        let htmlDocument = try await getHTMLDocument(for: request)
        let youtubeData = extractYoutubeJSData(fromHTMLDocument: htmlDocument)

        let collection = try EMYouTubeParser.parseCollection(fromYoutubeJSData: youtubeData)

        return collection
    }

    public func getTopHitMusicPlaylistCollections() async throws -> [EMYouTubePlaylistCollection] {
        guard let request = createHTMLRequest(path: Constants.topHitMusicPlaylistsURLPath) else {
            throw EMYouTubeScraperError.invalidRequest
        }

        let htmlDocument = try await getHTMLDocument(for: request)
        let youtubeData = extractYoutubeJSData(fromHTMLDocument: htmlDocument)

        let collections = try EMYouTubeParser.parsePlaylistCollections(fromYoutubeJSData: youtubeData)

        return collections
    }

    public func getPlaylistVideos(playlistId: String) async throws -> [EMYouTubeVideo] {
        let queryParams = [
            "list": playlistId
        ]
        guard let request = createHTMLRequest(path: Constants.playlistVideosPath, queryParams: queryParams) else {
            throw EMYouTubeScraperError.invalidRequest
        }

        let htmlDocument = try await getHTMLDocument(for: request)
        let youtubeData = extractYoutubeJSData(fromHTMLDocument: htmlDocument)

        let videos = try EMYouTubeParser.parsePlaylistVideos(fromYoutubeJSData: youtubeData)

        return videos
    }

    public func searchVideos(
        keyword: String
    ) async throws -> EMYouTubeSearchResult {
        guard let request = createHTMLRequest(
            path: Constants.searchPath,
            queryParams: [
                "search_query": keyword,
                "app": "desktop"
            ]
        ) else {
            throw EMYouTubeScraperError.invalidRequest
        }

        let htmlDocument = try await getHTMLDocument(for: request)
        let youtubeData = extractYoutubeJSData(fromHTMLDocument: htmlDocument)
        let searchResult = try EMYouTubeParser.parseSearchResult(fromYoutubeJSData: youtubeData)

        return searchResult
    }

    public func continueSearchVideos(
        continuationToken: String,
        context: [String: Any]?
    ) async throws -> EMYouTubeSearchResult  {
        var bodyJson: [String: Any] = [
            "continuation": continuationToken
        ]
        if let context {
            bodyJson["context"] = context
        }

        guard let request = createRestAPIRequest(
            path: Constants.continueSearchAPIPath,
            method: .POST,
            queryParams: [
                "prettyPrint": "false",
                "key": config.apiKey
            ],
            bodyJson: bodyJson
        ) else {
            throw EMYouTubeScraperError.invalidRequest
        }

        let jsonObject = try await getJsonObject(for: request)
        let searchResult = try EMYouTubeParser.parseContinueSearchResult(context: context, responseJson: jsonObject)

        return searchResult
    }

    public func getMixPlaylistVideos(forPlayingVideo videoId: String) async throws -> [EMYouTubeVideo] {
        let queryParams = [
            "v": videoId,
            "list": String(format: "RD%@", videoId)
        ]
        guard let request = createHTMLRequest(path: Constants.watchVideoPath, queryParams: queryParams) else {
            throw EMYouTubeScraperError.invalidRequest
        }

        let htmlDocument = try await getHTMLDocument(for: request)
        let youtubeData = extractYoutubeJSData(fromHTMLDocument: htmlDocument)

        let videos = try EMYouTubeParser.parseMixPlaylistVideos(fromYoutubeJSData: youtubeData)

        return videos
    }

    public func getVideoStream(videoId: String) async throws -> EMYouTubeVideoStream {
        guard !config.youtubePlayerConfigs.isEmpty else {
            throw EMYouTubeScraperError.internalError
        }

        // Try to get data from each client if failure
        var lastUnplayableStream: EMYouTubeVideoStream?

        for playerConfig in config.youtubePlayerConfigs {
            let bodyJson: [String: Any] = [
                "videoId": videoId,
                "contentCheckOk": true,
                "racyCheckOk": true,
                "context": [
                    "client": playerConfig["client"],
                    "thirdParty": [
                        "embedUrl": "https://www.youtube.com/"
                    ]
                ]
            ]

            var headers = [String: String]()
            if let userAgent = playerConfig["userAgent"] as? String {
                headers["User-Agent"] = userAgent
            }

            guard let request = createRestAPIRequest(
                path: Constants.playerAPIPath,
                method: .POST,
                queryParams: [
                    "key": (playerConfig["apiKey"] as? String) ?? config.apiKey
                ],
                headers: headers,
                bodyJson: bodyJson
            ) else {
                throw EMYouTubeScraperError.invalidRequest
            }

            let jsonObject = try await getJsonObject(for: request)
            var videoStream = EMYouTubeParser.parseVideoStream(
                fromDict: jsonObject,
                filterItags: config.supportedVideoItags
            )
            videoStream.requestUserAgent = headers["User-Agent"]

            if videoStream.playabilityStatus.playable {
                return videoStream
            } else {
                // Try to get with next client, but still keep the last result
                lastUnplayableStream = videoStream
            }
        }

        // If cannot fetch data for all clients, still return last stream if any
        if let lastUnplayableStream {
            return lastUnplayableStream
        } else {
            throw EMYouTubeScraperError.invalidRequest
        }
    }
}

extension EMYouTubeScraper: URLSessionDelegate {
    // Do nothing for now
}
