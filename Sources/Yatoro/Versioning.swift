import Foundation

public let yatoroVersionCore: String = "0.2.1"

fileprivate let readyForRelease: Bool = false

#if DEBUG

public let yatoroVersion: String = "dev-\(yatoroVersionCore)-\(VersionatorVersion.commit)"

#else

public let yatoroVersion: String =
    readyForRelease ? yatoroVersionCore : "rel-\(yatoroVersionCore)-\(VersionatorVersion.commit)"

#endif
