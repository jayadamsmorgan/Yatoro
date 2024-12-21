import Foundation
import TOMLKit
import Yams

struct ConfigurationParser {

    private var filePath: String
    private var url: URL

    private let fm: FileManager = FileManager.default

    public static var configFolderURL: URL {
        guard let envConfig = ProcessInfo.processInfo.environment["XDG_CONFIG_HOME"] else {
            return FileManager.default.homeDirectoryForCurrentUser
                .appendingPathComponent(".config", isDirectory: true)
                .appendingPathComponent("Yatoro", isDirectory: true)
        }
        return URL(fileURLWithPath: envConfig, isDirectory: true)
            .appendingPathComponent("Yatoro", isDirectory: true)
    }

    public static var themesFolderURL: URL {
        configFolderURL.appendingPathComponent("themes", isDirectory: true)
    }

    @MainActor
    public static func setupConfigurationDirectory() {
        let fm = FileManager.default
        if !fm.fileExists(atPath: configFolderURL.path) {
            do {
                try fm.createDirectory(atPath: configFolderURL.path, withIntermediateDirectories: true)
            } catch {
            }
        }
        do {
            let contents = try fm.contentsOfDirectory(atPath: configFolderURL.path)
            if !contents.contains("config.yaml"),
                !contents.contains("config.yml"),
                !contents.contains("config.toml"),
                !contents.contains("config.json")
            {
                fm.createFile(
                    atPath: configFolderURL.appendingPathComponent("config.yaml", isDirectory: false).path,
                    contents: Config.defaultConfigContents.data(using: .utf8)
                )
            }
            if !fm.fileExists(atPath: themesFolderURL.path) {
                try fm.createDirectory(
                    atPath: configFolderURL.appendingPathComponent("themes", isDirectory: true).path,
                    withIntermediateDirectories: true
                )
            }
            let themeContents = try fm.contentsOfDirectory(atPath: themesFolderURL.path)
            if themeContents.isEmpty {
                fm.createFile(
                    atPath: themesFolderURL.appendingPathComponent("default.yaml").path,
                    contents: Theme.defaultThemeConfigContents.data(using: .utf8)
                )
            }
        } catch {
        }
    }

    init?(customConfigPath: String?) {
        if let customConfigPath {
            self.filePath = customConfigPath
        } else {
            self.filePath =
                ConfigurationParser.configFolderURL
                .appendingPathComponent("config.yaml", isDirectory: false).path
        }
        if !fm.fileExists(atPath: self.filePath) {
            return nil
        }
        self.url = URL(fileURLWithPath: filePath, isDirectory: false)
    }

    @MainActor
    func loadConfig() {
        let name = self.url.lastPathComponent
        guard let fileType = ConfigFileType(fileName: name) else {
            return
        }
        do {
            switch fileType {
            case .yaml:
                Config.shared =
                    try ConfigurationParser.parseYAML(for: Config.self, file: self.filePath)
            case .json:
                Config.shared =
                    try ConfigurationParser.parseJSON(for: Config.self, file: self.filePath)
            case .toml:
                Config.shared =
                    try ConfigurationParser.parseTOML(for: Config.self, file: self.filePath)
            }
        } catch {
        }
    }

    @MainActor
    static func loadTheme() {
        let themeName = Config.shared.ui.theme
        do {
            let themes =
                try FileManager.default
                .contentsOfDirectory(atPath: ConfigurationParser.themesFolderURL.path)
            for theme in themes {
                let splitted = theme.split(separator: ".")
                guard splitted.count == 2 else {
                    continue
                }
                guard splitted.first! == themeName else {
                    continue
                }
                guard let filetype = ConfigFileType(fileName: theme) else {
                    continue
                }
                let fullThemePath =
                    ConfigurationParser.themesFolderURL
                    .appendingPathComponent(theme, isDirectory: false).path

                switch filetype {
                case .yaml:
                    Theme.shared =
                        try parseYAML(for: Theme.self, file: fullThemePath)
                case .toml:
                    Theme.shared =
                        try parseTOML(for: Theme.self, file: fullThemePath)
                case .json:
                    Theme.shared =
                        try parseJSON(for: Theme.self, file: fullThemePath)
                }
                return
            }
        } catch {
        }
    }

    // The functions below should be called only when we are sure the files exist
    private static func parseYAML<T>(for type: T.Type, file: String) throws -> T where T: Decodable {
        let decoder = YAMLDecoder()
        let contents = try String(contentsOfFile: file, encoding: .utf8)
        return try decoder.decode(type, from: contents)
    }

    private static func parseTOML<T>(for type: T.Type, file: String) throws -> T where T: Decodable {
        let decoder = TOMLDecoder()
        let contents = try String(contentsOfFile: file, encoding: .utf8)
        return try decoder.decode(type, from: contents)
    }

    private static func parseJSON<T>(for type: T.Type, file: String) throws -> T where T: Decodable {
        let decoder = JSONDecoder()
        let contents = try String(contentsOfFile: file, encoding: .utf8)
        return try decoder.decode(type, from: contents.data(using: .utf8)!)
    }
}

enum ConfigFileType: String {
    case yaml
    case toml
    case json

    init?(rawValue: String) {
        switch rawValue {
        case "yaml", "yml":
            self = .yaml
        case "toml":
            self = .toml
        case "json":
            self = .json
        default:
            return nil
        }
    }

    init?(fileName: String) {
        let splitted = fileName.split(separator: ".")
        guard splitted.count == 2 else {
            return nil
        }
        self.init(rawValue: String(splitted.last!).lowercased())
    }
}

extension Config {
    static let defaultConfigContents: String =
        """
        ui:
          frameDelay: 5000000

          artwork:
            width: 500
            height: 500

          layout:
            pages: [nowPlaying, queue, search]
            cols: 2
            rows: 2

        settings:
          disableSigInt: false

        logging:
          logLevel: info

        mappings:
          - key: SPACE
            modifiers:
            action: :playPauseToggle<CR>
        """
}

extension Theme {
    static let defaultThemeConfigContents: String =
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

        songDetail:
          border:
            fg: blue
          artistIndices:
            fg: cyan
          albumIndex:
            fg: yellow
          songTitle:
            fg: blue
          artistsText:
            fg: cyan
          albumText:
            fg: blue
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
            genreRight:
              fg: green
            albumsRight:
              fg: blue

        recommendationDetail:
          border:
            fg: blue

        artistDetail:
          border:
            fg: blue
          topSongIndices:
            fg: cyan
          albumIndices:
            fg: blue
          artistTitle:
            fg: blue
          topSongsText:
            fg: cyan
          albumsText:
            fg: blue
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
            genreRight:
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
