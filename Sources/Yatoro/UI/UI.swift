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

    public init() async {

        var flags: [UIOptionFlag] = [
            .inhibitSetLocale,
            .noFontChanges,
            .noWinchSighandler,
            .noQuitSighandlers,
        ]

        #if !DEBUG
        flags.append(.suppressBanners)
        #endif

        let config = Config.shared

        var opts = UIOptions(
            logLevel: config.logging.ncLogLevel,
            config: config.ui,
            flags: flags
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

        setupSigwinchHandler {
            if !config.settings.disableResize {
                await self.handleResize()
            }
        }
        setupSigintHandler {}

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

        await stop()
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
        // Only happens in iTerm2
        // Every other terminal just sends "unknown" instead
        // So this is actually how it is supposed to work
        guard input.eventType != .release else {
            return
        }
        logger?.trace("New input: \(input)")
        inputQueue.add(input)
    }

    public func stop() async {
        await pageManager.onQuit()
        logger?.info("Stopping Yatoro...")

        // Fix for artwork not getting destroyed in iTerm2
        UI.notcurses?.render()

        // Workaround for iTerm2 not recovering state after quitting Yatoro
        if let termProg = ProcessInfo.processInfo.environment["TERM_PROGRAM"],
            termProg == "iTerm.app"
        {
            if !Config.shared.settings.disableITermWorkaround {
                let sequence = "\u{1B}[=0u"
                FileHandle.standardOutput.write(sequence.data(using: .utf8)!)
            }
        }

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
