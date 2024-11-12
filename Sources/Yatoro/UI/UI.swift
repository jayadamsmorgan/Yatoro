import Foundation
import Logging
import SwiftNotCurses

@MainActor
public class UI {

    internal static var notcurses: NotCurses?

    private let inputQueue: InputQueue

    public static var running: Bool = true

    private let stdPlane: Plane

    private var pageManager: UIPageManager

    internal static var mode: UIMode = .normal

    private let frameDelay: UInt64

    public init(config: Config) async {
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

        self.frameDelay = config.ui.frameDelay

        self.inputQueue = InputQueue.shared
        inputQueue.mappings = config.mappings

        logger?.info("Initializing UI with options: \(opts)")
        guard let notcurses = NotCurses(opts: &opts) else {
            fatalError("Failed to initialize notcurses UI.")
        }
        UI.notcurses = notcurses
        logger?.debug("Notcurses initialized.")

        guard let stdPlane = Plane(in: notcurses) else {
            fatalError("Failed to initialize notcurses std plane")
        }
        self.stdPlane = stdPlane

        guard
            let pageManager = await UIPageManager(
                uiConfig: config.ui,
                stdPlane: stdPlane
            )
        else {
            fatalError("Failed to initiate PageManager.")
        }
        self.pageManager = pageManager
        await handleResize()

        setupSigwinchHandler(onResize: handleResize)
        setupSigintHandler(onStop: stop)

        logger?.info("UI initialized successfully.")
    }

    public func start() async {

        await pageManager.resizePages(stdPlane.width, stdPlane.height)

        await inputQueue.start()

        await appLoop()
    }

    private func appLoop() async {

        while UI.running {

            await handleInput()

            await pageManager.renderPages()

            UI.notcurses?.render()

            try! await Task.sleep(nanoseconds: frameDelay)
        }

        stop()
    }

    func handleResize() async {
        logger?.trace("Resize occured: Refreshing...")
        UI.notcurses?.refresh()
        let newWidth = stdPlane.width
        let newHeight = stdPlane.height
        logger?.trace(
            "Resize occured: New width \(newWidth), new height: \(newHeight)"
        )

        await pageManager.resizePages(newWidth, newHeight)
        await pageManager.windowTooSmallPage.render()

        logger?.debug("Resize handled.")
    }

    func handleInput() async {
        guard let notcurses = UI.notcurses else {
            return
        }
        guard let input = Input(notcurses: notcurses) else {
            return
        }
        logger?.trace("New input: \(input)")
        inputQueue.add(input)
    }

    public func stop() {
        logger?.info("Stopping Yatoro...")
        UI.notcurses?.stop()
        logger?.debug("Notcurses stopped.")
        logger?.info("Yatoro stopped.\n")
        exit(EXIT_SUCCESS)
    }

}

public enum UIMode {
    case normal
    case command
}
