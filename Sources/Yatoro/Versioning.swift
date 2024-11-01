import Foundation

public let yatoroVersionCore: String = "0.0.2"

fileprivate let readyForRelease: Bool = false

public let yatoroBuildUUID = UUID().uuidString

#if DEBUG

public let yatoroVersion: String =
    readyForRelease ? "\(yatoroVersionCore)-dev" : "dev-\(yatoroVersionCore)-\(yatoroBuildUUID)"

#else

public let yatoroVersion: String =
    readyForRelease ? yatoroVersionCore : "rel-\(yatoroVersionCore)-\(yatoroBuildUUID)"

#endif
