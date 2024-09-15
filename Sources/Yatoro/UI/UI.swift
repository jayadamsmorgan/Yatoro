import Foundation
import Logging
import notcurses

public struct UI {

    private let logger: Logger?

    private let notcurses: NotCurses
    private var opts: UIOptions

    private var running: Bool = true

    internal static var stateChanged: Bool = true

    public init(logger: Logger?, opts: UIOptions) {
        self.logger = logger
        self.opts = opts

        logger?.info("Initializing UI with options: \(opts)")
        guard let notcurses = NotCurses(logger: logger, opts: &self.opts) else {
            fatalError("Failed to initialize notcurses UI.")
        }
        self.notcurses = notcurses
        logger?.debug("Notcurses initialized.")

        logger?.info("UI initialized successfully.")

        setupSigwinchHandler()
    }

    public func start() async {
        guard let stdPlane = Plane(in: notcurses, logger: logger) else {
            fatalError("Failed to initialize notcurses std plane")
        }
        guard
            let first = Plane(
                in: stdPlane,
                opts: PlaneOptions(
                    x: 50,
                    y: 30,
                    width: 50,
                    height: 3,
                    debugID: "FIRST",
                    flags: [],
                    bottomMargin: 0,
                    rightMargin: 0
                ),
                logger: logger
            )
        else {
            fatalError("Failed to initialize first plane")
        }
        ncplane_putstr(first.ncplane, "TEST")

        await appLoop()
    }

    private func appLoop() async {

        while running {

            handleInput()

            if UI.stateChanged {
                notcurses_render(notcurses.pointer)
                UI.stateChanged = false
            }

            if resizeOccurred != 0 {
                notcurses_refresh(notcurses.pointer, nil, nil)
                notcurses_render(notcurses.pointer)
                resizeOccurred = 0
            }

            try! await Task.sleep(nanoseconds: 10_000_000)
        }
    }

    func handleInput() {
        guard let input = Input(notcurses: notcurses) else {
            return
        }
        logger?.trace("New input: \(input)")
        if input.utf8 == "q" {
            stop()
        }
        UI.stateChanged = true
    }

    public func stop() {
        notcurses_stop(notcurses.pointer)
        exit(EXIT_SUCCESS)
    }

}
