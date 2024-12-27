import Foundation
import Logging
import SwiftNotCurses
import Yams

public struct Config {

    @MainActor public static var shared: Config = .init()

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

    @MainActor static internal func applyArgumentOptions(
        uiOptions: UIArgOptions,
        loggingOptions: LoggingArgOptions,
        settingsOptions: SettingsArgOptions
    ) {
        var config = Config.shared

        // Settings
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

        Config.shared = config
    }

    @MainActor static internal func processMappings() {
        var config = Config.shared

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
