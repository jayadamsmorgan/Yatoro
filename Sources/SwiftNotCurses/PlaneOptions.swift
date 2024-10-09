import notcurses

public class PlaneOptions {

    public let x: Int32
    public let y: Int32

    public let width: UInt32
    public let height: UInt32

    public let debugID: String?
    public let flags: [PlaneOptionFlags]

    public let bottomMargin: UInt32
    public let rightMargin: UInt32

    internal var ncPlaneOptions: ncplane_options

    public init(
        x: Int32 = 0,
        y: Int32 = 0,
        width: UInt32 = 0,
        height: UInt32 = 0,
        debugID: String? = nil,
        flags: [PlaneOptionFlags] = [],
        bottomMargin: UInt32 = 0,
        rightMargin: UInt32 = 0
    ) {
        self.x = x
        self.y = y
        self.width = width
        self.height = height
        self.debugID = debugID
        self.flags = flags
        self.bottomMargin = bottomMargin
        self.rightMargin = rightMargin

        self.ncPlaneOptions = ncplane_options(
            y: y,
            x: x,
            rows: height,
            cols: width,
            userptr: nil,
            name: String.convertToUnsafePointer(from: debugID),
            resizecb: nil,
            flags: PlaneOptionFlags.flagsToUInt64(flags),
            margin_b: bottomMargin,
            margin_r: rightMargin
        )
    }
}

public enum PlaneOptionFlags: UInt64 {
    case horizontalAlignment
    case verticalAlignment
    case marginalized
    case fixed
    case autogrow
    case verticalScrolling
}

extension PlaneOptionFlags {
    fileprivate static func flagsToUInt64(_ flags: [PlaneOptionFlags]) -> UInt64 {
        var result: UInt64 = 0
        for flag in flags {
            result |= flag.rawValue
        }
        return result
    }
}

extension String {
    public static func convertToUnsafePointer(from string: String?)
        -> UnsafePointer<CChar>?
    {
        guard let unwrappedString = string else {
            return nil
        }
        let cString = unwrappedString.cString(using: .utf8)
        return cString?.withUnsafeBufferPointer { buffer in
            return buffer.baseAddress
        }
    }
}
