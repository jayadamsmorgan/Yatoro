import Foundation
import Logging
import notcurses

public actor UI {

    private let logger: Logger?

    private let notcurses: NotCurses

    private let inputQueue: InputQueue

    public static var running: Bool = true

    internal static var stateChanged: Bool = true

    private var pages: [Page] = []

    internal static var mode: UIMode = .normal

    public init(logger: Logger?, config: Config) {
        self.logger = logger
        var opts = UIOptions(
            logLevel: config.logging!.ncLogLevel!,
            config: config.ui!,
            flags: [
                .inhibitSetLocale, .noFontChanges, .noWinchSighandler,
                .noQuitSighandlers,
            ]
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

    public func start() async {
        guard let stdPlane = Plane(in: notcurses, logger: logger) else {
            fatalError("Failed to initialize notcurses std plane")
        }

        guard let playerPage = PlayerPage(stdPlane: stdPlane, logger: logger)
        else {
            logger?.critical("Failed to initiate Player Page.")
            stop()
            return
        }

        guard let searchPage = SearchPage(stdPlane: stdPlane, logger: logger)
        else {
            logger?.critical("Failed to initiate Search Page.")
            stop()
            return
        }

        guard let commandPage = CommandPage(stdPlane: stdPlane, logger: logger)
        else {
            logger?.critical("Failed to initiate Command Page.")
            stop()
            return
        }

        self.pages = [playerPage, searchPage, commandPage]

        await inputQueue.start()

        await appLoop()
    }

    private func appLoop() async {

        while UI.running {

            await handleInput()

            for page in pages {
                await page.render()
            }

            notcurses_render(notcurses.pointer)

            if resizeOccurred != 0 {
                notcurses_refresh(notcurses.pointer, nil, nil)
                notcurses_render(notcurses.pointer)
                resizeOccurred = 0
            }

            // TODO: make it configurable through config too
            try! await Task.sleep(nanoseconds: 3_500_000)
        }

        stop()
    }

    func handleInput() async {
        guard let input = Input(notcurses: notcurses) else {
            return
        }
        logger?.trace("New input: \(input)")
        await inputQueue.add(input)
        UI.stateChanged = true
    }

    public func stop() {
        logger?.info("Stopping Yatoro...")
        notcurses_stop(notcurses.pointer)
        logger?.debug("Notcurses stopped.")
        logger?.info("Yatoro stopped.\n")
        exit(EXIT_SUCCESS)
    }

}

public enum UIMode {
    case normal
    case command
}
