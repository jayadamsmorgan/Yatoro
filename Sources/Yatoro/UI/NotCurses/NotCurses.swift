import Logging
import notcurses

public struct NotCurses {
    var pointer: OpaquePointer
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

}
