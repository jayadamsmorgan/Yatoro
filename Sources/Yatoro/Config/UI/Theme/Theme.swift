import Foundation
import SwiftNotCurses

public struct Theme {

    @MainActor public static var shared: Theme = .init()

    public init() {
        self.nowPlaying = .init()
        self.commandLine = .init()
        self.search = .init()
        self.queue = .init()

        self.songDetail = .init()
        self.artistDetail = .init()
        self.recommendationDetail = .init()
        self.albumDetail = .init()
        self.playlistDetail = .init()
    }

    public var nowPlaying: NowPlaying
    public var commandLine: CommandLine
    public var search: Search
    public var queue: Queue

    public var songDetail: SongDetail
    public var artistDetail: ArtistDetail
    public var recommendationDetail: RecommendationDetail
    public var albumDetail: AlbumDetail
    public var playlistDetail: PlaylistDetail
}

extension Theme: Codable {

    enum CodingKeys: String, CodingKey {
        case nowPlaying
        case commandLine
        case item
        case search
        case queue

        case songDetail
        case artistDetail
        case recommendationDetail
        case albumDetail
        case playlistDetail
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.nowPlaying =
            try container.decodeIfPresent(NowPlaying.self, forKey: .nowPlaying) ?? .init()
        self.commandLine =
            try container.decodeIfPresent(CommandLine.self, forKey: .commandLine) ?? .init()
        self.search =
            try container.decodeIfPresent(Search.self, forKey: .search) ?? .init()
        self.queue =
            try container.decodeIfPresent(Queue.self, forKey: .queue) ?? .init()

        self.songDetail =
            try container.decodeIfPresent(SongDetail.self, forKey: .songDetail) ?? .init()
        self.artistDetail =
            try container.decodeIfPresent(ArtistDetail.self, forKey: .artistDetail) ?? .init()
        self.recommendationDetail =
            try container.decodeIfPresent(RecommendationDetail.self, forKey: .recommendationDetail) ?? .init()
        self.albumDetail =
            try container.decodeIfPresent(AlbumDetail.self, forKey: .albumDetail) ?? .init()
        self.playlistDetail =
            try container.decodeIfPresent(PlaylistDetail.self, forKey: .playlistDetail) ?? .init()
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(nowPlaying, forKey: .nowPlaying)
        try container.encode(commandLine, forKey: .commandLine)
        try container.encode(search, forKey: .search)
        try container.encode(queue, forKey: .queue)
        try container.encode(songDetail, forKey: .songDetail)
        try container.encode(artistDetail, forKey: .artistDetail)
        try container.encode(recommendationDetail, forKey: .recommendationDetail)
        try container.encode(albumDetail, forKey: .albumDetail)
        try container.encode(playlistDetail, forKey: .playlistDetail)
    }

}
