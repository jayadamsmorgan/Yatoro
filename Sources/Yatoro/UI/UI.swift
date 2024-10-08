import Foundation
import Logging
import notcurses

public actor UI {

    private let notcurses: NotCurses

    private let inputQueue: InputQueue

    public static var running: Bool = true

    private let stdPlane: Plane

    private var pageManager: UIPageManager

    internal static var mode: UIMode = .normal

    internal var minRequiredDim: (minWidth: UInt32, minHeight: UInt32) = (0, 0)

    public init(config: Config) {
        var opts = UIOptions(
            logLevel: config.logging.ncLogLevel,
            config: config.ui,
            flags: [
                .inhibitSetLocale,
                .noFontChanges,
                .noWinchSighandler,
                .noQuitSighandlers,
            ]
        )

        self.inputQueue = .init(mappings: config.mappings)

        logger?.info("Initializing UI with options: \(opts)")
        guard let notcurses = NotCurses(opts: &opts) else {
            fatalError("Failed to initialize notcurses UI.")
        }
        self.notcurses = notcurses
        logger?.debug("Notcurses initialized.")

        setupSigwinchHandler()

        guard let stdPlane = Plane(in: notcurses) else {
            fatalError("Failed to initialize notcurses std plane")
        }
        self.stdPlane = stdPlane

        guard let commandPage = CommandPage(stdPlane: stdPlane)
        else {
            fatalError("Failed to initiate Command Page.")
        }

        guard
            let windowTooSmallPage = WindowTooSmallPage(
                stdPlane: stdPlane
            )
        else {
            fatalError("Failed to initiate Window Too Small Page.")
        }
        self.pageManager = .init(
            layoutConfig: config.ui.layout,
            commandPage: commandPage,
            windowTooSmallPage: windowTooSmallPage,
            stdPlane: stdPlane
        )

        logger?.info("UI initialized successfully.")
    }

    public func start() async {
        self.minRequiredDim = await pageManager.minimumRequiredDiminsions()
        await pageManager.windowTooSmallPage
            .setMinRequiredDim(minRequiredDim)

        await pageManager.resizePages(stdPlane.width, stdPlane.height)

        await inputQueue.start()

        await appLoop()
    }

    private func appLoop() async {

        while UI.running {

            await handleInput()

            await handleResize()

            await pageManager.renderPages()

            notcurses_render(notcurses.pointer)

            // TODO: make it configurable through config too
            try! await Task.sleep(nanoseconds: 5_000_000)
        }

        stop()
    }

    func handleResize() async {
        // TODO: resizeOccurred is not thread safe property, needs to be fixed
        if resizeOccurred != 0 {
            resizeOccurred = 0
            logger?.trace("Resize occured: Refreshing...")
            notcurses_refresh(notcurses.pointer, nil, nil)
            let newWidth = stdPlane.width
            let newHeight = stdPlane.height
            logger?.trace(
                "Resize occured: New width \(newWidth), new height: \(newHeight)"
            )

            await pageManager.resizePages(newWidth, newHeight)

            logger?.debug("Resize handled.")
        }
        await pageManager.windowTooSmallPage.render()
    }

    func handleInput() async {
        guard let input = Input(notcurses: notcurses) else {
            return
        }
        logger?.trace("New input: \(input)")
        await inputQueue.add(input)
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
