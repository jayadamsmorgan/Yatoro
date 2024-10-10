import Foundation
import Logging
import SwiftNotCurses
import Yams

public struct Config {

    public var mappings: [Mapping]
    public var ui: UIConfig
    public var logging: LoggingConfig

    public init() {
        self.mappings = []
        self.ui = .init()
        self.logging = .init()
    }

}

public extension Config {

    static let defaultConfigPath = FileManager.default
        .homeDirectoryForCurrentUser
        .appendingPathComponent(".config", isDirectory: true)
        .appendingPathComponent("Yatoro", isDirectory: true)
        .appendingPathComponent("config.yaml")
        .path

    static func load(from path: String, logLevel: Logger.Level?) -> Config {
        let fm = FileManager.default
        let fileURL = URL(fileURLWithPath: path)
        if !fm.fileExists(atPath: path) && path == defaultConfigPath {
            do {
                try fm.createDirectory(
                    at: fileURL.deletingLastPathComponent(),
                    withIntermediateDirectories: true
                )
            } catch {
                return .init()
            }
            FileManager.default.createFile(atPath: path, contents: nil)
            return .init()
        }

        do {
            let yamlString = try String(contentsOf: fileURL, encoding: .utf8)
            let decoder = YAMLDecoder()
            let config = try decoder.decode(Config.self, from: yamlString)
            return config
        } catch is DecodingError {
            if let logLevel, logLevel <= .info {
                print(
                    "[INFO]: Failed to parse config: Config is either empty or incorrect."
                )
            }
            return .init()
        } catch {
            fatalError(error.localizedDescription)
        }
    }

    @MainActor static internal func parseOptions(
        uiOptions: UIArgOptions,
        loggingOptions: LoggingArgOptions,
        configPath: String
    )
        -> Config
    {
        // Loading config from default config path
        var config = load(from: configPath, logLevel: loggingOptions.logLevel)

        // Then we overwrite it with command line arguments

        // Logging
        if let logLevel = loggingOptions.logLevel {
            config.logging.logLevel = logLevel
        }
        if let ncLogLevel = loggingOptions.ncLogLevel {
            config.logging.ncLogLevel = ncLogLevel
        }
        // UI - Margins
        if let marginsAll = uiOptions.margins {
            config.ui.margins.all = marginsAll
        }
        if let marginLeft = uiOptions.leftMargin {
            config.ui.margins.left = marginLeft
        }
        if let marginRight = uiOptions.rightMargin {
            config.ui.margins.left = marginRight
        }
        if let marginTop = uiOptions.topMargin {
            config.ui.margins.top = marginTop
        }
        if let marginBot = uiOptions.bottomMargin {
            config.ui.margins.bottom = marginBot
        }
        // UI - Frame delay
        if let frameDelay = uiOptions.frameDelay {
            config.ui.frameDelay = frameDelay
        }
        // UI - Layout
        if let cols = uiOptions.layoutOptions.cols {
            config.ui.layout.cols = cols
        }
        if let rows = uiOptions.layoutOptions.rows {
            config.ui.layout.rows = rows
        }

        // Mappings processing
        var newMappings = Mapping.defaultMappings
        for mapping in config.mappings {
            let index = newMappings.firstIndex(where: {
                $0.action == mapping.action
            })!
            newMappings[index] = mapping
        }
        // TODO: check for duplicates and other funny stuff
        config.mappings = newMappings

        return config
    }
}

extension Config {

    public struct LoggingConfig {

        var logLevel: Logger.Level?
        var ncLogLevel: UILogLevel

        public init() {
            self.logLevel = nil
            self.ncLogLevel = .silent
        }

    }

}

extension Config {

    public struct UIConfig {

        var margins: Margins
        var frameDelay: UInt64
        var layout: UILayoutConfig

        public init() {
            self.margins = .init()
            self.layout = .init()
            self.frameDelay = 5_000_000
        }

        public struct Margins {
            public var all: UInt32
            public var left: UInt32?
            public var right: UInt32?
            public var top: UInt32?
            public var bottom: UInt32?

            public init() {
                self.all = 0
            }

        }
    }
}

extension Config.UIConfig {

    public struct UILayoutConfig {
        public var rows: UInt32
        public var cols: UInt32

        public var pages: [Pages]

        public enum Pages: String, Decodable {
            case nowPlaying
            case queue
            case search
        }

        public init() {
            self.rows = 2
            self.cols = 2
            pages = [.nowPlaying, .search, .queue]
        }
    }
}

extension Config.UIConfig.UILayoutConfig: Decodable {

    enum CodingKeys: String, CodingKey {
        case rows
        case cols
        case pages
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.rows =
            try container.decodeIfPresent(UInt32.self, forKey: .rows) ?? 2
        self.cols =
            try container.decodeIfPresent(UInt32.self, forKey: .cols) ?? 2
        self.pages =
            try container.decodeIfPresent([Pages].self, forKey: .pages) ?? [.nowPlaying, .search, .queue]
    }

}

extension Config: Decodable {

    enum CodingKeys: String, CodingKey {
        case mappings
        case ui
        case logging
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.mappings =
            try container.decodeIfPresent([Mapping].self, forKey: .mappings) ?? []
        self.ui =
            try container.decodeIfPresent(UIConfig.self, forKey: .ui) ?? .init()
        self.logging =
            try container.decodeIfPresent(LoggingConfig.self, forKey: .logging) ?? .init()
    }

}

extension Config.LoggingConfig: Decodable {

    enum CodingKeys: String, CodingKey {
        case logLevel
        case ncLogLevel
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.logLevel =
            try container.decodeIfPresent(Logger.Level.self, forKey: .logLevel)
        self.ncLogLevel =
            try container.decodeIfPresent(UILogLevel.self, forKey: .ncLogLevel) ?? .silent
    }

}

extension Config.UIConfig: Decodable {

    enum CodingKeys: String, CodingKey {
        case margins
        case layout
        case frameDelay
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.margins =
            try container.decodeIfPresent(Margins.self, forKey: .margins) ?? .init()
        self.layout =
            try container.decodeIfPresent(UILayoutConfig.self, forKey: .layout) ?? .init()
        self.frameDelay =
            try container.decodeIfPresent(UInt64.self, forKey: .frameDelay) ?? 5_000_000
    }

}

extension Config.UIConfig.Margins: Decodable {

    enum CodingKeys: String, CodingKey {
        case all
        case left
        case right
        case top
        case bottom
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.all =
            try container.decodeIfPresent(UInt32.self, forKey: .all) ?? 0
        self.left =
            try container.decodeIfPresent(UInt32.self, forKey: .left)
        self.right =
            try container.decodeIfPresent(UInt32.self, forKey: .right)
        self.top =
            try container.decodeIfPresent(UInt32.self, forKey: .top)
        self.bottom =
            try container.decodeIfPresent(UInt32.self, forKey: .bottom)
    }
}
