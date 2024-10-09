import notcurses

public struct UIOptions {
    var notcursesOptions: notcurses_options
    var optionFlags: [UIOptionFlag]
    var leftMargin: UInt32
    var rightMargin: UInt32
    var bottomMargin: UInt32
    var topMargin: UInt32

    public init(
        logLevel: UILogLevel = .silent,
        leftMargin: UInt32 = 0,
        rightMargin: UInt32 = 0,
        bottomMargin: UInt32 = 0,
        topMargin: UInt32 = 0,
        flags: [UIOptionFlag] = UIOptionFlag.cliMode()
    ) {
        self.optionFlags = flags
        self.notcursesOptions = .init(
            termtype: nil,
            loglevel: .init(logLevel.rawValue),
            margin_t: topMargin,
            margin_r: rightMargin,
            margin_b: bottomMargin,
            margin_l: leftMargin,
            flags: UIOptionFlag.flagsToUInt64(flags: flags)
        )
        self.leftMargin = leftMargin
        self.rightMargin = rightMargin
        self.topMargin = topMargin
        self.bottomMargin = bottomMargin
    }

}

public enum UILogLevel: Int32, Decodable {
    case silent = -1
    case panic = 0
    case fatal = 1
    case error = 2
    case warning = 3
    case info = 4
    case verbose = 5
    case debug = 6
    case trace = 7
}

public enum UIOptionFlag: UInt64 {
    case inhibitSetLocale = 0x0001
    case noClearBitmaps = 0x0002
    case noWinchSighandler = 0x0004
    case noQuitSighandlers = 0x0008
    case preserveCursor = 0x0010
    case suppressBanners = 0x0020
    case noAlternateScreen = 0x0040
    case noFontChanges = 0x0080
    case drainInput = 0x0100
    case scrolling = 0x0200

    public static func cliMode() -> [UIOptionFlag] {
        [
            .noAlternateScreen,
            .noClearBitmaps,
            .preserveCursor,
            .scrolling,
        ]
    }

    fileprivate static func flagsToUInt64(flags: [UIOptionFlag]) -> UInt64 {
        var result: UInt64 = 0
        for flag in flags {
            result |= flag.rawValue
        }
        return result
    }

}
