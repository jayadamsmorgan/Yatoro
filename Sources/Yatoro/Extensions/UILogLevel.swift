import ArgumentParser
import SwiftNotCurses

extension UILogLevel: ExpressibleByArgument {

    public init?(argument: String) {
        switch argument.lowercased() {
        case "info": self = .info
        case "debug": self = .debug
        case "error": self = .error
        case "fatal": self = .fatal
        case "panic": self = .panic
        case "trace": self = .trace
        case "silent": self = .silent
        case "verbose": self = .verbose
        case "warning": self = .warning
        default: return nil
        }
    }

}
