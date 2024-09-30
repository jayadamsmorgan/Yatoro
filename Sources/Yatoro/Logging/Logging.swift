import ArgumentParser
import Foundation
import Logging

public let loggerLabel: String = "yatoro"

extension Logger {
    func trace(_ message: String) {
        trace(Logger.Message(stringLiteral: message))
    }

    func debug(_ message: String) {
        debug(Logger.Message(stringLiteral: message))
    }

    func info(_ message: String) {
        info(Logger.Message(stringLiteral: message))
    }

    func warning(_ message: String) {
        warning(Logger.Message(stringLiteral: message))
    }

    func error(_ message: String) {
        error(Logger.Message(stringLiteral: message))
    }

    func critical(_ message: String) {
        critical(Logger.Message(stringLiteral: message))
    }
}

extension Logger.Level: ExpressibleByArgument {

}

public struct FileLogger: LogHandler, Sendable {
    public var logLevel: Logger.Level
    public var metadata: Logger.Metadata
    public var fileURL: URL
    public var fileHandle: FileHandle?

    public subscript(metadataKey key: String) -> Logger.Metadata.Value? {
        get {
            metadata[key]
        }
        set(newValue) {
            metadata[key] = newValue
        }
    }

    private let label: String

    public init(
        label: String,
        filePath: String,
        logLevel: Logger.Level,
        metadata: Logger.Metadata = [:]
    ) {
        self.label = label
        self.logLevel = logLevel
        self.metadata = metadata
        self.fileURL = URL(string: filePath)!
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: filePath) {
            fileManager.createFile(
                atPath: filePath,
                contents: nil,
                attributes: nil
            )
        }
        self.fileHandle = try! FileHandle(forUpdating: fileURL)
        self.fileHandle?.seekToEndOfFile()
    }

    public func log(
        level: Logger.Level,
        message: Logger.Message,
        metadata: Logger.Metadata?,
        file: String,
        function: String,
        line: UInt
    ) {
        let metadataString =
            metadata?.map { "\($0)=\($1)" }.joined(separator: " ") ?? ""
        let timestamp = Date().formattedLogTimestamp()
        let logLevel = level.rawValue.uppercased()
        let logMessage =
            "[\(timestamp)] [\((logLevel))]: \(message) \(metadataString)\n"
        fileHandle?.write(logMessage.data(using: .utf8)!)
    }
}

extension Date {
    func formattedLogTimestamp() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: self)
    }
}
