import ArgumentParser
import Logging
import MusicKit
import SwiftNotCurses

struct LoggingArgOptions: ParsableArguments {
    @Option(
        name: .shortAndLong,
        help: "Set app log level (default: none)",
        completion: .default
    )
    var logLevel: Logger.Level?

    @Option(
        name: .shortAndLong,
        help: "Set notcurses log level (default: silent)",
        completion: .default
    )
    var ncLogLevel: UILogLevel?
}

struct SettingsArgOptions: ParsableArguments {

    @Flag(
        name: .long,
        help: "Disable UI resizing (default: false (Resizing enabled))"
    )
    var disableResize: Bool = false

    @Option(
        name: .long,
        help: "Limit amount of search items, must be greater than 0 (default: 10)"
    )
    var searchItemLimit: UInt32?
}

struct UIArgOptions: ParsableArguments {
    @Option(
        name: .shortAndLong,
        help: "Set UI theme (default: \"default\")",
        completion: .default
    )
    var theme: String?

    @Option(
        name: .shortAndLong,
        help: "Set UI margins, must be greater than 0 (default: 0)",
        completion: .default
    )
    var margins: UInt32?

    @Option(
        name: .long,
        help: "Set left UI margin, must be greater than 0 (default: 0)",
        completion: .default
    )
    var leftMargin: UInt32?

    @Option(
        name: .long,
        help: "Set right UI margin, must be greater than 0 (default: 0)",
        completion: .default
    )
    var rightMargin: UInt32?

    @Option(
        name: .long,
        help: "Set top UI margin, must be greater than 0 (default: 0)",
        completion: .default
    )
    var topMargin: UInt32?

    @Option(
        name: .long,
        help: "Set bottom UI margin, must be greater than 0 (default: 0)",
        completion: .default
    )
    var bottomMargin: UInt32?

    @Option(
        name: .shortAndLong,
        help: "Set UI frame delay in nanoseconds (default: 5_000_000)",
        completion: .default
    )
    var frameDelay: UInt64?

    @OptionGroup(title: "Layout", visibility: .default)
    var layoutOptions: UILayoutOptions

    struct UILayoutOptions: ParsableArguments {

        @Option(
            name: .long,
            help: "Amount of rows in UI (default: 2)",
            completion: .default
        )
        var rows: UInt32?

        @Option(
            name: .long,
            help: "Amount of columns in UI (default: 2)",
            completion: .default
        )
        var cols: UInt32?

    }

}

@main
struct Yatoro: AsyncParsableCommand {

    static let configuration: CommandConfiguration = .init(
        commandName: "yatoro",
        abstract: "Apple Music CLI Player",
        version: "Yatoro version: \(yatoroVersion)"
    )

    @OptionGroup(title: "Logging", visibility: .default)
    var loggingOptions: LoggingArgOptions

    @OptionGroup(title: "UI", visibility: .default)
    var uiOptions: UIArgOptions

    @OptionGroup(title: "Settings", visibility: .default)
    var settingsOptions: SettingsArgOptions

    @Option(
        name: .shortAndLong,
        help: "Custom path to config file",
        completion: .file(extensions: ["yaml", "yml", "toml", "json"])
    )
    var config: String?

    @MainActor private func initLogging() {
        guard let logLevel = Config.shared.logging.logLevel else {
            return
        }
        logger = Logger(label: loggerLabel) {
            FileLogger(label: $0, filePath: $0 + ".log", logLevel: logLevel)
        }
    }

    @MainActor
    mutating func run() async throws {

        ConfigurationParser.setupConfigurationDirectory()

        guard let configParser = ConfigurationParser(customConfigPath: config) else {
            print("Error: Unable to find config at \(config!)")
            return
        }

        configParser.loadConfig()

        Config.applyArgumentOptions(
            uiOptions: uiOptions,
            loggingOptions: loggingOptions,
            settingsOptions: settingsOptions
        )
        Config.processMappings()

        ConfigurationParser.loadTheme()

        initLogging()
        logger?.info("Starting Yatoro...")
        logger?.debug("Config:\n\(Config.shared)")

        let player = Player.shared
        await player.authorize()

        let ui = await UI()
        await ui.start()
    }
}
