import Logging
import notcurses

public struct NotCurses {
    var pointer: OpaquePointer
    var opts: UIOptions

    private var logger: Logger?

    init?(logger: Logger?, opts: inout UIOptions, setLocale: Bool = true) {
        self.logger = logger

        if setLocale {
            setlocale(LC_ALL, "")
        }

        guard let pointer = notcurses_core_init(&opts.notcursesOptions, nil) else {
            logger?.error("Failed to initialize notcurses core.")
            return nil
        }
        self.pointer = pointer
        self.opts = opts

    }

}
