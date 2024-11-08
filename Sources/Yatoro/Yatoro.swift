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

struct UIArgOptions: ParsableArguments {
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

    @Option(
        name: .shortAndLong,
        help: "Custom path to config.yaml",
        completion: .file(extensions: ["yaml"])
    )
    var config: String = Config.defaultConfigPath

    @MainActor private func initLogging(config: Config.LoggingConfig) {
        guard let logLevel = config.logLevel else {
            return
        }
        logger = Logger(label: loggerLabel) {
            FileLogger(label: $0, filePath: $0 + ".log", logLevel: logLevel)
        }
    }

    @MainActor
    mutating func run() async throws {
        let config = Config.parseOptions(
            uiOptions: uiOptions,
            loggingOptions: loggingOptions,
            configPath: config
        )

        initLogging(config: config.logging)
        logger?.info("Starting Yatoro...")
        logger?.debug("Config:\n\(config)")

        let player = Player.shared
        await player.authorize()

        let ui = await UI(config: config)
        await ui.start()
    }
}
