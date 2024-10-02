import Foundation
import Logging
import Yams

public struct Config: Decodable {

    public var mappings: [Mapping]?
    public var ui: UIConfig?
    public var logging: LoggingConfig?

}

public extension Config {

    static let defaultConfigPath = FileManager.default
        .homeDirectoryForCurrentUser
        .appendingPathComponent(".config", isDirectory: true)
        .appendingPathComponent("Yatoro", isDirectory: true)
        .appendingPathComponent("config.yaml")
        .path

    static func load(from path: String) -> Config? {
        let fm = FileManager.default
        let fileURL = URL(fileURLWithPath: path)
        if !fm.fileExists(atPath: path) && path == defaultConfigPath {
            do {
                try fm.createDirectory(
                    at: fileURL.deletingLastPathComponent(),
                    withIntermediateDirectories: true
                )
            } catch {
                return nil
            }
            FileManager.default.createFile(atPath: path, contents: nil)
            return nil
        }

        do {
            let yamlString = try String(contentsOf: fileURL, encoding: .utf8)
            let decoder = YAMLDecoder()
            let config = try decoder.decode(Config.self, from: yamlString)
            if config.ui == nil && config.logging == nil
                && config.mappings == nil
            {
                return nil
            }
            return config

        } catch {
            return nil
        }
    }

    static internal func parseOptions(
        uiOptions: UIArgOptions,
        loggingOptions: LoggingArgOptions,
        configPath: String
    )
        -> Config
    {
        // Loading config from default config path
        // If it's empty or not there we create a default one
        var config =
            load(from: configPath)
            ?? Config(mappings: Mapping.defaultMappings, ui: nil, logging: nil)

        // Then we overwrite it with command line arguments or set the default ones:

        // Logging
        config.logging = config.logging ?? .init()
        config.logging!.logLevel =
            loggingOptions.logLevel ?? config.logging!.logLevel
        config.logging!.ncLogLevel =
            loggingOptions.ncLogLevel ?? config.logging!.ncLogLevel ?? .silent
        // Margins
        config.ui = config.ui ?? .init()
        config.ui!.margins = config.ui!.margins ?? .init()
        config.ui!.margins!.all =
            uiOptions.margins ?? config.ui!.margins!.all ?? 0
        config.ui!.margins!.top = uiOptions.topMargin ?? config.ui!.margins!.top
        config.ui!.margins!.left =
            uiOptions.leftMargin ?? config.ui!.margins!.left
        config.ui!.margins!.right =
            uiOptions.rightMargin ?? config.ui!.margins!.right
        config.ui!.margins!.bottom =
            uiOptions.bottomMargin ?? config.ui!.margins!.bottom
        // Mappings
        if let mappings = config.mappings {
            var newMappings = Mapping.defaultMappings
            for mapping in mappings {
                let index = newMappings.firstIndex(where: {
                    $0.action == mapping.action
                })!
                newMappings[index] = mapping
            }
            // TODO: check for duplicates and other funny stuff
            config.mappings = newMappings
        } else {
            config.mappings = Mapping.defaultMappings
        }

        return config
    }
}

extension Config {

    public struct LoggingConfig: Decodable {

        var logLevel: Logger.Level?
        var ncLogLevel: UILogLevel?

    }

    public struct UIConfig: Decodable {

        var margins: Margins?

        public struct Margins: Decodable {
            public var all: UInt32?
            public var left: UInt32?
            public var right: UInt32?
            public var top: UInt32?
            public var bottom: UInt32?
        }
    }

}
