import notcurses

public struct Input: Sendable {
    public let id: UInt32
    public let x: Int32
    public let y: Int32

    public let utf8: String

    public let modifiers: [Modifier]
    public let eventType: EventType

    public let pixelXOffset: Int32
    public let pixelYOffset: Int32

    public init(id: UInt32 = 0, utf8: String = "", modifiers: [Modifier] = []) {
        self.id = id
        self.x = 0
        self.y = 0
        self.utf8 = utf8
        self.modifiers = modifiers
        self.eventType = .unknown
        self.pixelXOffset = 0
        self.pixelYOffset = 0
    }

    public init?(notcurses: NotCurses) {
        var ncinput = ncinput()
        guard notcurses_get_nblock(notcurses.pointer, &ncinput) != 0 else {
            return nil
        }
        self.id = ncinput.id
        self.x = ncinput.x
        self.y = ncinput.y
        var utf8 = String.init(
            utf8String: [
                ncinput.utf8.0,
                ncinput.utf8.1,
                ncinput.utf8.2,
                ncinput.utf8.3,
                ncinput.utf8.4,
            ])!

        self.pixelXOffset = ncinput.xpx
        self.pixelYOffset = ncinput.ypx

        self.eventType = EventType.init(rawValue: ncinput.evtype.rawValue) ?? .unknown

        var modifiers: [Modifier] = []
        if ncinput_ctrl_p(&ncinput) {
            utf8 = utf8.lowercased()
            modifiers.append(.ctrl)
        }
        if ncinput_shift_p(&ncinput) {
            modifiers.append(.shift)
        }
        if ncinput_alt_p(&ncinput) {
            modifiers.append(.alt)
        }
        if ncinput_meta_p(&ncinput) {
            modifiers.append(.meta)
        }
        if ncinput_super_p(&ncinput) {
            modifiers.append(.super)
        }
        if ncinput_hyper_p(&ncinput) {
            modifiers.append(.hyper)
        }
        self.utf8 = utf8
        self.modifiers = modifiers
    }

    public enum Modifier: String, Codable, Sendable {
        case shift
        case ctrl
        case alt
        case meta
        case `super`
        case hyper
        case capslock
        case numlock
    }

    public enum EventType: UInt32, Sendable {
        case unknown = 0
        case press = 1
        case `repeat` = 2
        case release = 3
    }
}
