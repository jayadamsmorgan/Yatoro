import Logging
import SwiftNotCurses

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
