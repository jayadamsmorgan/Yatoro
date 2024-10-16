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

extension Config: Codable {

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

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.ui, forKey: .ui)
        try container.encode(self.logging, forKey: .logging)
        try container.encode(self.mappings, forKey: .mappings)
    }

}

extension Config: CustomStringConvertible {
    public var description: String {
        let encoder = YAMLEncoder()
        do {
            return try encoder.encode(self)
        } catch {
            return "Encoding error"
        }
    }
}
