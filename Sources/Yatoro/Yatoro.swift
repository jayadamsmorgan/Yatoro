import ArgumentParser
import Logging

struct LoggingArgOptions: ParsableArguments {
    @Option(
        name: .shortAndLong,
        help: "Set app log level. Default: none.",
        completion: .default
    )
    var logLevel: Logger.Level?

    @Option(
        name: .shortAndLong,
        help: "Set notcurses log level. Default: silent.",
        completion: .default
    )
    var ncLogLevel: UILogLevel = .silent
}

struct UIArgOptions: ParsableArguments {
    @Option(
        name: .shortAndLong,
        help: "Set UI margins, must be greater than 0. Default: 0.",
        completion: .default
    )
    var margins: UInt32 = 0
}

@main
struct Yatoro: AsyncParsableCommand {

    @OptionGroup(title: "Logging", visibility: .default)
    var loggingOptions: LoggingArgOptions

    @OptionGroup(title: "UI", visibility: .default)
    var uiOptions: UIArgOptions

    public func initLogging() -> Logger? {
        guard let logLevel = loggingOptions.logLevel else {
            return nil
        }
        let logger: Logger = Logger(label: loggerLabel) {
            FileLogger(label: $0, filePath: $0 + ".log", logLevel: logLevel)
        }
        return logger
    }

    mutating func run() async throws {
        let logger = initLogging()
        let opts = UIOptions(
            logLevel: loggingOptions.ncLogLevel,
            margins: uiOptions.margins,
            flags: [.inhibitSetLocale, .noFontChanges, .noWinchSighandler]
        )

        let player = Player.shared
        player.logger = logger
        await player.authorize()

        var ui = UI(logger: logger, opts: opts)
        await ui.start()
    }
}
