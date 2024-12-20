import Foundation
import Logging
import SwiftNotCurses
import Yams

public struct Config {

    @MainActor public static var shared: Config = .init()
    @MainActor public static var path = defaultConfigPath

    public var mappings: [Mapping]
    public var ui: UIConfig
    public var logging: LoggingConfig
    public var settings: Settings

    public init() {
        self.mappings = []
        self.ui = .init()
        self.logging = .init()
        self.settings = .init()
    }

}

public extension Config {

    static let yatoroConfigFolder = FileManager.default
        .homeDirectoryForCurrentUser
        .appendingPathComponent(".config", isDirectory: true)
        .appendingPathComponent("Yatoro", isDirectory: true)
        .path

    static let defaultConfigPath = yatoroConfigFolder + "/config.yaml"

    @MainActor
    static func load(logLevel: Logger.Level?) {
        let fm = FileManager.default
        let fileURL = URL(fileURLWithPath: path)
        if !fm.fileExists(atPath: path) && path == defaultConfigPath {
            do {
                try fm.createDirectory(
                    at: fileURL.deletingLastPathComponent(),
                    withIntermediateDirectories: true
                )
            } catch {
                return
            }
            FileManager.default.createFile(atPath: path, contents: nil)
            return
        }

        do {
            let yamlString = try String(contentsOf: fileURL, encoding: .utf8)
            let decoder = YAMLDecoder()
            let config = try decoder.decode(Config.self, from: yamlString)
            Config.shared = config
        } catch is DecodingError {
            if let logLevel, logLevel <= .info {
                print(
                    "[INFO]: Failed to parse config: Config is either empty or incorrect."
                )
            }
            return
        } catch {
            fatalError(error.localizedDescription)
        }
    }

    @MainActor static internal func parseOptions(
        uiOptions: UIArgOptions,
        loggingOptions: LoggingArgOptions,
        settingsOptions: SettingsArgOptions,
        configPath: String
    ) {
        // Loading config from config path
        path = configPath
        load(logLevel: loggingOptions.logLevel)
        var config = Config.shared

        // Then we overwrite it with command line arguments

        // Settings
        if settingsOptions.disableSigint {
            config.settings.disableSigInt = true
        }
        if settingsOptions.disableResize {
            config.settings.disableResize = true
        }
        if let searchItemLimit = settingsOptions.searchItemLimit {
            config.settings.searchItemLimit = searchItemLimit
        }
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
        for var mapping in config.mappings {
            mapping.key = mapping.key.trimmingCharacters(in: .whitespaces)
            if mapping.remap {
                if let modifiers = mapping.modifiers {
                    newMappings.removeAll(where: {
                        $0.key == mapping.key && $0.modifiers != nil && $0.modifiers!.elementsEqual(modifiers)
                    })
                } else {
                    newMappings.removeAll(where: {
                        $0.key == mapping.key && (mapping.modifiers == nil || mapping.modifiers!.isEmpty)
                    })
                }
            }
            newMappings.append(mapping)
        }

        // Remove SHIFT from all mappings and just uppercase the keys
        // This is done because notcurses is not registering shift for some reason
        for mappingIndex in newMappings.indices {
            if let mods = newMappings[mappingIndex].modifiers {
                if mods.contains(.shift) {
                    newMappings[mappingIndex].key = newMappings[mappingIndex].key.uppercased()
                    newMappings[mappingIndex].modifiers!.removeAll { mod in
                        mod == .shift
                    }
                }
            }
        }

        config.mappings = newMappings

        Config.shared = config
    }
}

extension Config: Codable {

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.mappings =
            try container.decodeIfPresent([Mapping].self, forKey: .mappings) ?? []
        self.ui =
            try container.decodeIfPresent(UIConfig.self, forKey: .ui) ?? .init()
        self.logging =
            try container.decodeIfPresent(LoggingConfig.self, forKey: .logging) ?? .init()
        self.settings =
            try container.decodeIfPresent(Settings.self, forKey: .settings) ?? .init()
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
