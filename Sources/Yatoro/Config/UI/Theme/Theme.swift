import Foundation
import SwiftNotCurses
import Yams

public struct Theme {

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

    private static let defaultThemeConfigContents: String =
        """
        commandLine:
          modeNormal:
            fg: red
          modeCommand:
            fg: green
          playStatus:
            fg: blue
          nowPlayingArtist:
            fg: cyan
          nowPlayingTitle:
            fg: magenta
          time:
            fg: yellow
          completions:
            bg: black
          completionSelected:
            bg: brightBlack

        nowPlaying:
          page:
            fg: yellow
          pageName:
            fg: blue
          border:
            fg: blue
          songRight:
            fg: magenta
          albumRight:
            fg: blue
          artistRight:
            fg: cyan
          controls:
            fg: blue
          sliderKnob:
            fg: blue
          duration:
            fg: yellow
          currentTime:
            fg: yellow

        search:
          border:
            fg: red
          pageName:
            fg: red
          itemIndices:
            fg: cyan
          albumItem:
            border:
              fg: blue
            pageName:
              fg: blue
            albumRight:
              fg: blue
            artistRight:
              fg: cyan
            genreRight:
              fg: green

          artistItem:
            border:
              fg: cyan
            pageName:
              fg: cyan
            artistRight:
              fg: cyan
            genresRight:
              fg: green
            albumsRight:
              fg: blue

          playlistItem:
            border:
              fg: yellow
            pageName:
              fg: yellow
            playlistRight:
              fg: yellow
            curatorRight:
              fg: blue
            descriptionRight:
              fg: green

          stationItem:
            border:
              fg: magenta
            pageName:
              fg: magenta
            stationRight:
              fg: magenta
            isLiveRight:
              fg: blue
            notesRight:
              fg: green
              
          songItem:
            border:
              fg: cyan
            pageName:
              fg: cyan
            songRight:
              fg: magenta
            albumRight:
              fg: blue
            artistRight:
              fg: cyan

          recommendationItem:
            border:
              fg: red
            pageName:
              fg: red
            titleRight:
              fg: red
            refreshDateRight:
              fg: green
            typesRight:
              fg: cyan
            

        queue:
          border:
            fg: magenta
          pageName:
            fg: magenta
          shuffleMode:
            fg: magenta
          repeatMode:
            fg: magenta
          songItem:
            border:
              fg: blue
            pageName:
              fg: blue
            songRight:
              fg: magenta
            albumRight:
              fg: blue
            artistRight:
              fg: cyan
        """
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

    private static func loadDefault() -> Theme {
        let fm = FileManager.default
        let fullThemePath = Config.yatoroConfigFolder + "/themes/default.yaml"
        if fm.fileExists(atPath: fullThemePath) {
            do {
                return try loadYAML(themePath: fullThemePath)
            } catch {
                print("Error: Unable to load default theme: \(error.localizedDescription)")
                print("Error: Using no theme.")
                return Theme()
            }
        }
        do {
            try fm.createDirectory(atPath: Config.yatoroConfigFolder + "/themes", withIntermediateDirectories: true)
        } catch {
            print("Error: Unable to create \(Config.yatoroConfigFolder)/themes: \(error.localizedDescription)")
            print("Error: Using no theme.")
            return Theme()
        }
        if !fm.createFile(
            atPath: fullThemePath,
            contents: defaultThemeConfigContents.data(using: .utf8)
        ) {
            print("Error: Unable to create \(Config.yatoroConfigFolder)/themes/default.yaml.")
            print("Error: Using no theme.")
            return Theme()
        }
        do {
            return try loadYAML(themePath: fullThemePath)
        } catch {
            print("Error: Unable to load default theme: \(error.localizedDescription)")
            print("Error: Using no theme")
            return Theme()
        }
    }

    public static func load(theme: String) -> Theme {
        let fm = FileManager.default
        if theme == "default" {
            return loadDefault()
        }
        let fullThemePath = Config.yatoroConfigFolder + "/themes/" + theme
        do {
            if fm.fileExists(atPath: fullThemePath + ".json") {
                return try loadJSON(themePath: fullThemePath + ".json")

            } else if fm.fileExists(atPath: fullThemePath + ".yaml") {
                return try loadYAML(themePath: fullThemePath + ".yaml")

            } else if fm.fileExists(atPath: fullThemePath + ".yml") {
                return try loadYAML(themePath: fullThemePath + ".yml")

            } else if fm.fileExists(atPath: fullThemePath + ".toml") {
                return try loadTOML(themePath: fullThemePath + ".toml")
            }
        } catch {
            print("Error: Error loading theme \(theme): \(error.localizedDescription)")
            print("Error: Using default theme instead.")
            return loadDefault()
        }

        // Could not find theme
        print("Warning: Theme \(theme) was not found. Using default instead.")
        return loadDefault()
    }

    private static func loadTOML(themePath: String) throws -> Theme {
        print("Warning: TOML theme loading is not implemented yet. Using default theme.")
        return loadDefault()
    }

    private static func loadYAML(themePath: String) throws -> Theme {
        let decoder = YAMLDecoder()
        let url = URL(fileURLWithPath: themePath)
        let string = try String(contentsOf: url, encoding: .utf8)
        return try decoder.decode(Theme.self, from: string)
    }

    private static func loadJSON(themePath: String) throws -> Theme {
        let decoder = JSONDecoder()
        let url = URL(fileURLWithPath: themePath)
        let data = try String(contentsOf: url, encoding: .utf8).data(using: .utf8)!
        return try decoder.decode(Theme.self, from: data)
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
