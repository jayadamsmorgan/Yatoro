import Logging
import MusicKit
import SwiftNotCurses

public actor CommandPage: Page {

    private let plane: Plane

    private var state: PageState

    private var cursorState = CursorState((0, 0), enabled: false)

    private var size: PageSize {
        if state.width < 20 {
            return .nano
        }
        if state.width < 40 {
            return .mini
        }
        if state.width < 60 {
            return .default
        }
        if state.width < 80 {
            return .plus
        }
        return .mega
    }

    public func onResize(newPageState: PageState) async {
        self.state = newPageState
        plane.updateByPageState(state)
    }

    public func getPageState() async -> PageState { self.state }

    public func getMinDimensions() async -> (width: UInt32, height: UInt32) { return (10, 2) }

    public func getMaxDimensions() async -> (width: UInt32, height: UInt32)? { nil }

    public init?(stdPlane: Plane) {
        self.state = .init(
            absX: 0,
            absY: Int32(stdPlane.height) - 2,
            width: stdPlane.width,
            height: 2
        )
        guard
            let plane = Plane(
                in: stdPlane,
                opts: .init(
                    x: 0,
                    y: Int32(stdPlane.height) - 2,
                    width: state.width,
                    height: state.height,
                    debugID: "COMMAND_PAGE"
                )
            )
        else {
            return nil
        }
        self.plane = plane
    }

    public func render() async {
        var firstLineLeft = ""
        var firstLineRight = ""

        // MODE
        switch size {
        case .nano, .mini:
            switch UI.mode {
            case .normal:
                firstLineLeft += "N  "
            case .command:
                firstLineLeft += "C  "
            }
        case .default:
            switch UI.mode {
            case .normal:
                firstLineLeft += "NRML  "
            case .command:
                firstLineLeft += "CMD  "
            }
        case .plus, .mega:
            switch UI.mode {
            case .normal:
                firstLineLeft += "NORMAL  "
            case .command:
                firstLineLeft += "COMMAND  "
            }
        }

        // PLAYER STATUS
        switch Player.shared.status {
        case .stopped:
            switch size {
            case .nano, .mini, .default:
                firstLineLeft += "#  "
            case .plus, .mega:
                firstLineLeft += "# Stopped  "
            }
        case .playing:
            switch size {
            case .nano, .mini, .default:
                firstLineLeft += "▶  "
            case .plus, .mega:
                firstLineLeft += "▶ Playing  "
            }
        case .paused:
            switch size {
            case .nano, .mini, .default:
                firstLineLeft += "⏸  "
            case .plus, .mega:
                firstLineLeft += "⏸ Paused  "
            }
        case .interrupted:
            switch size {
            case .nano, .mini, .default:
                firstLineLeft += "//  "
            case .plus, .mega:
                firstLineLeft += "// Interrupted  "
            }
        case .seekingForward:
            switch size {
            case .nano, .mini, .default:
                firstLineLeft += "▶▶  "
            case .plus, .mega:
                firstLineLeft += "▶▶ Seeking  "
            }
        case .seekingBackward:
            switch size {
            case .nano, .mini, .default:
                firstLineLeft += "◀◀  "
            case .plus, .mega:
                firstLineLeft += "◀◀ Seeking  "
            }
        @unknown default:
            switch size {
            case .nano, .mini, .default:
                firstLineLeft += "?  "
            case .plus, .mega:
                firstLineLeft += "? Unknown  "
            }
        }

        var secondLine: String
        if (UI.mode == .command) {
            secondLine = ":\(await CommandInput.shared.get())"
            let absolutePlanePositionY = state.absY
            let cursorY = absolutePlanePositionY + 1
            let cursorX =
                Int32(await CommandInput.shared.getCursorPosition()) + 1
            if (cursorState.x != cursorX || !cursorState.enabled) {
                logger?.debug("Cursor update")
                UI.notcurses?.enableCursor(at: (cursorX, cursorY))
                self.cursorState.x = cursorX
                self.cursorState.y = cursorY
                self.cursorState.enabled = true
            }
        } else {
            if (cursorState.enabled) {
                UI.notcurses?.disableCursor()
                cursorState.enabled = false
            }
            secondLine = await CommandInput.shared.getLastCommandOutput()
        }
        if secondLine.count < state.width {
            secondLine += String(
                repeating: " ",
                count: Int(state.width) - secondLine.count
            )
        } else if UI.mode == .command {
            secondLine = String(
                secondLine.dropFirst(secondLine.count - Int(state.width))
            )
        }

        guard let nowPlaying = Player.shared.nowPlaying else {
            if size == .default || size == .plus || size == .mega {
                if Int(state.width) - firstLineLeft.count > 0 {
                    firstLineLeft += String(
                        repeating: " ",
                        count: Int(state.width) - firstLineLeft.count
                    )
                }
                firstLineRight += "--:--/--:--"
            } else {
                firstLineLeft += String(
                    repeating: " ",
                    count: Int(state.width) - firstLineLeft.count
                )
            }
            printSections(
                firstLineLeft: firstLineLeft,
                firstLineRight: firstLineRight,
                secondLine: secondLine
            )
            return
        }

        firstLineRight +=
            Player.shared.player.playbackTime.toMMSS() + "/"
            + (nowPlaying.duration?.toMMSS() ?? "--:--")

        switch size {
        case .nano, .mini: break
        case .default:
            firstLineLeft += "\(nowPlaying.title)"
        case .plus, .mega:
            firstLineLeft +=
                "\(nowPlaying.artistName) - \(nowPlaying.title)"
        }

        guard state.width > firstLineLeft.count else {
            plane.putString(firstLineLeft, at: (0, 0))
            return
        }

        firstLineLeft.append(
            String(
                repeating: " ",
                count: Int(state.width) - firstLineLeft.count
            )
        )

        printSections(
            firstLineLeft: firstLineLeft,
            firstLineRight: firstLineRight,
            secondLine: secondLine
        )
    }

    private func printSections(
        firstLineLeft: String,
        firstLineRight: String,
        secondLine: String
    ) {
        plane.putString(firstLineLeft, at: (0, 0))
        plane.putString(
            firstLineRight,
            at: (Int32(state.width) - Int32(firstLineRight.count), 0)
        )
        plane.putString(secondLine, at: (0, 1))
    }
}
