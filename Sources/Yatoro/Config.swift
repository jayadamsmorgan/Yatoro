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
        var colors: Colors

        public init() {
            self.margins = .init()
            self.layout = .init()
            self.frameDelay = 5_000_000
            self.colors = .init()
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

extension Plane.Color: Codable {

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.red, forKey: .r)
        try container.encode(self.green, forKey: .g)
        try container.encode(self.blue, forKey: .b)
    }

    enum CodingKeys: String, CodingKey {
        case r
        case red

        case g
        case green

        case b
        case blue

        case type
    }

    public init(from decoder: any Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.red =
            try container.decodeIfPresent(UInt8.self, forKey: .r)
            ?? container.decodeIfPresent(UInt8.self, forKey: .red)
            ?? 0
        self.green =
            try container.decodeIfPresent(UInt8.self, forKey: .g)
            ?? container.decodeIfPresent(UInt8.self, forKey: .green)
            ?? 0
        self.blue =
            try container.decodeIfPresent(UInt8.self, forKey: .b)
            ?? container.decodeIfPresent(UInt8.self, forKey: .blue)
            ?? 0
    }

    public init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if hexSanitized.hasPrefix("#") {
            hexSanitized.remove(at: hexSanitized.startIndex)
        }

        guard hexSanitized.count == 6 else {
            return nil
        }

        var rgbValue: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgbValue)

        self.init()
        self.red = UInt8((rgbValue & 0xFF0000) >> 16)
        self.green = UInt8((rgbValue & 0x00FF00) >> 8)
        self.blue = UInt8(rgbValue & 0x0000FF)
    }

}

extension Config.UIConfig {

    public struct Colors {

        public init() {
            self.nowPlaying = .init()
        }

        public var nowPlaying: NowPlaying

        public struct ColorPair {
            var foreground: Plane.Color?
            var background: Plane.Color?

            public init() {
                self.foreground = nil
                self.background = nil
            }

        }

        public struct NowPlaying {
            public var page: ColorPair
            public var border: ColorPair
            public var pageName: ColorPair
            public var slider: ColorPair
            public var sliderKnob: ColorPair
            public var controls: ColorPair
            public var itemDescriptionLeft: ColorPair
            public var itemDescriptionRight: ColorPair

            public init() {
                self.page = .init()
                self.border = .init()
                self.pageName = .init()
                self.slider = .init()
                self.sliderKnob = .init()
                self.controls = .init()
                self.itemDescriptionLeft = .init()
                self.itemDescriptionRight = .init()
            }
        }

    }

}

extension Config.UIConfig.Colors.NowPlaying: Codable {

    enum CodingKeys: String, CodingKey, CaseIterable {
        case page
        case pageName
        case border
        case slider
        case sliderKnob
        case controls

        case itemDescLeft

        case itemDescRight
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.page =
            try container.decodeIfPresent(Config.UIConfig.Colors.ColorPair.self, forKey: .page)
            ?? .init()
        self.pageName =
            try container.decodeIfPresent(Config.UIConfig.Colors.ColorPair.self, forKey: .pageName)
            ?? .init()
        self.border =
            try container.decodeIfPresent(Config.UIConfig.Colors.ColorPair.self, forKey: .border)
            ?? .init()
        self.slider =
            try container.decodeIfPresent(Config.UIConfig.Colors.ColorPair.self, forKey: .slider)
            ?? .init()
        self.sliderKnob =
            try container.decodeIfPresent(Config.UIConfig.Colors.ColorPair.self, forKey: .sliderKnob)
            ?? .init()
        self.itemDescriptionLeft =
            try container.decodeIfPresent(Config.UIConfig.Colors.ColorPair.self, forKey: .itemDescLeft)
            ?? .init()
        self.itemDescriptionRight =
            try container.decodeIfPresent(Config.UIConfig.Colors.ColorPair.self, forKey: .itemDescRight)
            ?? .init()
        self.controls =
            try container.decodeIfPresent(Config.UIConfig.Colors.ColorPair.self, forKey: .controls)
            ?? .init()
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.page, forKey: .page)
        try container.encode(self.pageName, forKey: .pageName)
        try container.encode(self.border, forKey: .border)
        try container.encode(self.itemDescriptionLeft, forKey: .itemDescLeft)
        try container.encode(self.itemDescriptionRight, forKey: .itemDescRight)
        try container.encode(self.slider, forKey: .slider)
        try container.encode(self.sliderKnob, forKey: .sliderKnob)
        try container.encode(self.controls, forKey: .controls)
    }

}

extension Config.UIConfig.Colors: Codable {

    enum CodingKeys: String, CodingKey {
        case nowPlaying
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.nowPlaying = try container.decodeIfPresent(NowPlaying.self, forKey: .nowPlaying) ?? .init()
    }

}

extension Config.UIConfig.Colors.ColorPair: Codable {
    enum CodingKeys: String, CodingKey {
        case fg
        case bg
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let fgStr = try container.decodeIfPresent(String.self, forKey: .fg) {
            if let defaultColor = Plane.Color.DefaultColors(rawValue: fgStr) {
                self.foreground = .init(color: defaultColor)
            } else {
                self.foreground = .init(hex: fgStr)
            }
        }
        if let bgStr = try container.decodeIfPresent(String.self, forKey: .bg) {
            if let defaultColor = Plane.Color.DefaultColors(rawValue: bgStr) {
                self.background = .init(color: defaultColor)
            } else {
                self.background = .init(hex: bgStr)
            }
        }
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        if let foreground {
            switch foreground.type {
            case .palette:
                try container.encode(foreground.paletteName, forKey: .fg)
            case .rgb:
                try container.encode(foreground, forKey: .fg)
            }
        }
        if let background {
            switch background.type {
            case .palette:
                try container.encode(background.paletteName, forKey: .bg)
            case .rgb:
                try container.encode(background, forKey: .bg)
            }
        }
    }
}

extension Config.UIConfig {

    public struct UILayoutConfig {
        public var rows: UInt32
        public var cols: UInt32

        public var pages: [Pages]

        public enum Pages: String, Codable {
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

extension Config.UIConfig.UILayoutConfig: Codable {

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

extension Config.LoggingConfig: Codable {

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

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.logLevel, forKey: .logLevel)
        try container.encode(self.ncLogLevel.rawValue, forKey: .ncLogLevel)
    }

}

extension Config.UIConfig: Codable {

    enum CodingKeys: String, CodingKey {
        case margins
        case layout
        case frameDelay
        case colors
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.margins =
            try container.decodeIfPresent(Margins.self, forKey: .margins) ?? .init()
        self.layout =
            try container.decodeIfPresent(UILayoutConfig.self, forKey: .layout) ?? .init()
        self.frameDelay =
            try container.decodeIfPresent(UInt64.self, forKey: .frameDelay) ?? 5_000_000
        self.colors =
            try container.decodeIfPresent(Colors.self, forKey: .colors) ?? .init()
    }

}

extension Config.UIConfig.Margins: Codable {

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
