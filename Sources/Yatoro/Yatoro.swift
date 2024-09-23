import ArgumentParser
import Logging
import MusicKit

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

}

@main
struct Yatoro: AsyncParsableCommand {

    @OptionGroup(title: "Logging", visibility: .default)
    var loggingOptions: LoggingArgOptions

    @OptionGroup(title: "UI", visibility: .default)
    var uiOptions: UIArgOptions

    @Option(
        name: .shortAndLong,
        help: "Custom path to config.yaml",
        completion: .file(extensions: ["yaml"])
    )
    var configPath: String = Config.defaultConfigPath

    private func initLogging(config: Config.LoggingConfig) -> Logger? {
        guard let logLevel = config.logLevel else {
            return nil
        }
        let logger: Logger = Logger(label: loggerLabel) {
            FileLogger(label: $0, filePath: $0 + ".log", logLevel: logLevel)
        }
        return logger
    }

    mutating func run() async throws {
        let config = Config.parseOptions(
            uiOptions: uiOptions,
            loggingOptions: loggingOptions,
            configPath: configPath
        )

        let logger = initLogging(config: config.logging!)

        let player = Player.shared
        player.logger = logger
        await player.authorize()

        // Some music to play while started, remove when SearchPage is done :)
        // let result = await player.defaultSearch(for: "classic music")
        // if let songs = result?.songs {
        //     await player.playNext(songs)
        //     await player.play()
        // }
        // await player.recentlyPlayedRequest()
        var recommended = await player.getUserRecommendedBatch()
        if let recommended {
            logger?.info("\(recommended)")
            await player.playNext(recommended.first!.playlists.first!)
            await player.play()
        }

        var ui = UI(logger: logger, config: config)
        await ui.start()
    }
}
