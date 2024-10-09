import Logging
import notcurses

public struct NotCurses {

    internal var pointer: OpaquePointer
    var opts: UIOptions

    init?(opts: inout UIOptions, setLocale: Bool = true) {

        if setLocale {
            setlocale(LC_ALL, "")
        }

        guard let pointer = notcurses_core_init(&opts.notcursesOptions, nil)
        else {
            logger?.error("Failed to initialize notcurses core.")
            return nil
        }
        self.pointer = pointer
        self.opts = opts

    }

    public func render() {
        notcurses_render(pointer)
    }

    public func refresh() {
        notcurses_refresh(pointer, nil, nil)
    }

    public func stop() {
        notcurses_stop(pointer)
    }

    public func enableCursor(at position: (x: Int32, y: Int32)) {
        notcurses_cursor_enable(pointer, position.y, position.x)
    }

    public func disableCursor() {
        notcurses_cursor_disable(pointer)
    }

}
