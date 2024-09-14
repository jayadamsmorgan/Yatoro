import AVFoundation
import ArgumentParser
import Foundation
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
        help: "Path to directory where log file should be saved. Default: Current working directory.",
        completion: .directory
    )
    var fileLogPath: String?

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

    @Option(
        name: .shortAndLong,
        help: "Set UI blocking time in nanoseconds. Default: 10_000_000.",
        completion: .default
    )
    var blockingTime: Int = 10_000_000
}

@main
struct Yatoro: ParsableCommand {

    @OptionGroup(title: "Logging", visibility: .default)
    var loggingOptions: LoggingArgOptions

    @OptionGroup(title: "UI", visibility: .default)
    var uiOptions: UIArgOptions

    public func initLogging() -> Logger? {
        guard let logLevel = loggingOptions.logLevel else {
            return nil
        }
        guard var fileLogPath = loggingOptions.fileLogPath else {
            let logger: Logger = Logger(label: loggerLabel) {
                FileLogger(label: $0, filePath: $0 + ".log", logLevel: logLevel)
            }
            return logger
        }
        if fileLogPath.last != "/" {
            fileLogPath.append("/")
        }
        let logger: Logger = Logger(label: loggerLabel) {
            FileLogger(label: $0, filePath: fileLogPath + $0 + ".log", logLevel: logLevel)
        }
        return logger
    }

    mutating func run() throws {
        let logger = initLogging()
        let opts = UIOptions(
            logLevel: loggingOptions.ncLogLevel,
            margins: uiOptions.margins,
            flags: [.inhibitSetLocale, .noFontChanges, .noWinchSighandler],
            blockingTime: uiOptions.blockingTime
        )

        let ui = UI(logger: logger, opts: opts)
        ui.start()
    }
}
