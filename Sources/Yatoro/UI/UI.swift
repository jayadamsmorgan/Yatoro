import Foundation
import Logging
import notcurses

public struct UI {

    private let logger: Logger?

    private let notcurses: NotCurses

    private let inputQueue: InputQueue

    public static var running: Bool = true

    internal static var stateChanged: Bool = true

    private var pages: [Page] = []

    private var playerPage: PlayerPage?

    public init(logger: Logger?, config: Config) {
        self.logger = logger
        var opts = UIOptions(
            logLevel: config.logging!.ncLogLevel!,
            config: config.ui!,
            flags: [.inhibitSetLocale, .noFontChanges, .noWinchSighandler]
        )

        self.inputQueue = .init(mappings: config.mappings!, logger: logger)

        logger?.info("Initializing UI with options: \(opts)")
        guard let notcurses = NotCurses(logger: logger, opts: &opts) else {
            fatalError("Failed to initialize notcurses UI.")
        }
        self.notcurses = notcurses
        logger?.debug("Notcurses initialized.")

        setupSigwinchHandler()

        logger?.info("UI initialized successfully.")
    }

    public mutating func start() async {
        guard let stdPlane = Plane(in: notcurses, logger: logger) else {
            fatalError("Failed to initialize notcurses std plane")
        }

        guard let playerPage = PlayerPage(stdPlane: stdPlane, logger: logger) else {
            logger?.critical("Failed to initiate Player Page.")
            stop()
            return
        }
        self.playerPage = playerPage
        self.pages = [playerPage]

        await inputQueue.start()

        await appLoop()
    }

    private func appLoop() async {

        while UI.running {

            await handleInput()

            for page in pages {
                page.render()
            }

            notcurses_render(notcurses.pointer)

            if resizeOccurred != 0 {
                notcurses_refresh(notcurses.pointer, nil, nil)
                notcurses_render(notcurses.pointer)
                resizeOccurred = 0
            }

            try! await Task.sleep(nanoseconds: 10_000_000)
        }

        stop()
    }

    func handleInput() async {
        guard let input = Input(notcurses: notcurses) else {
            return
        }
        logger?.trace("New input: \(input)")
        inputQueue.add(input)
        UI.stateChanged = true
    }

    public func stop() {
        logger?.info("Stopping Yatoro...\n")
        notcurses_stop(notcurses.pointer)
        logger?.debug("Notcurses stopped.")
        exit(EXIT_SUCCESS)
    }

}
