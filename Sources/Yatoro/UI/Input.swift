import notcurses

public struct Input {
    public let id: UInt32
    public let x: Int32
    public let y: Int32

    public let utf8: String

    public let modifiers: [Modifier]
    public let eventType: EventType

    public let pixelXOffset: Int32
    public let pixelYOffset: Int32

    public init?(notcurses: NotCurses, blockingTime: Int) {
        var ncinput = ncinput()
        var timespec = timespec(tv_sec: 0, tv_nsec: blockingTime)
        guard notcurses_get(notcurses.pointer, &timespec, &ncinput) != 0 else {
            return nil
        }
        self.id = ncinput.id
        self.x = ncinput.x
        self.y = ncinput.y
        self.utf8 = String.init(
            utf8String: [
                ncinput.utf8.0,
                ncinput.utf8.1,
                ncinput.utf8.2,
                ncinput.utf8.3,
                ncinput.utf8.4,
            ])!  // Should not fail I think...

        self.pixelXOffset = ncinput.xpx
        self.pixelYOffset = ncinput.ypx

        self.eventType = EventType.init(rawValue: ncinput.evtype.rawValue) ?? .unknown

        var modifiers: [Modifier] = []
        if ncinput_shift_p(&ncinput) {
            modifiers.append(.shift)
        }
        if ncinput_ctrl_p(&ncinput) {
            modifiers.append(.ctrl)
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
        if ncinput_capslock_p(&ncinput) {
            modifiers.append(.capslock)
        }
        if ncinput_numlock_p(&ncinput) {
            modifiers.append(.numlock)
        }
        self.modifiers = modifiers
    }

    public enum Modifier {
        case shift
        case ctrl
        case alt
        case meta
        case `super`
        case hyper
        case capslock
        case numlock
    }

    public enum EventType: UInt32 {
        case unknown = 0
        case press = 1
        case `repeat` = 2
        case release = 3
    }
}
