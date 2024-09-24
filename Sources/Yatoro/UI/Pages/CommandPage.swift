import Logging
import MusicKit
import notcurses

// TODO: Move it somewhere later as we would probably need to manage the cursor not only here I guess...
public struct CursorState {
    public var x: Int32
    public var y: Int32
    public var enabled: Bool

    public init(_ pair: (x: Int32, y: Int32), enabled: Bool) {
        self.x = pair.x
        self.y = pair.y
        self.enabled = enabled
    }
}

public class CommandPage: Page {

    public var plane: Plane
    public var logger: Logging.Logger?

    public var width: UInt32
    public var height: UInt32 = 2

    private let output: Output

    private var lastAbsY: Int32 = 0

    private var cursorState = CursorState((0, 0), enabled: false)

    private var size: YatoroSize {
        if width < 20 {
            return .nano
        }
        if width < 40 {
            return .mini
        }
        if width < 60 {
            return .default
        }
        if width < 80 {
            return .plus
        }
        return .mega
    }

    public init?(stdPlane: Plane, logger: Logger?) {
        self.plane = stdPlane
        self.logger = logger
        self.width = stdPlane.width

        guard
            let plane = Plane(
                in: stdPlane,
                opts: .init(
                    x: 0,
                    y: Int32(stdPlane.height) - 2,
                    width: width,
                    height: height,
                    debugID: "COMMAND_PAGE"
                ),
                logger: logger
            )
        else {
            return nil
        }
        self.plane = plane
        self.output = .init(plane: plane)
    }

    public func render() async {

        self.width = plane.parentPlane!.width

        let absY = Int32(plane.parentPlane!.height) - 2
        if absY != lastAbsY {
            lastAbsY = absY
            ncplane_move_yx(
                plane.ncplane,
                Int32(plane.parentPlane!.height) - 2,
                0
            )
        }

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
            let absolutePlanePositionY = ncplane_abs_y(self.plane.ncplane)
            let cursorY = absolutePlanePositionY + 1
            let cursorX =
                Int32(await CommandInput.shared.getCursorPosition()) + 1
            if (cursorState.x != cursorX || !cursorState.enabled) {
                logger?.debug("Cursor update")
                notcurses_cursor_enable(
                    plane.parentPlane!.notcurses!.pointer,
                    cursorY,
                    cursorX
                )
                self.cursorState.x = cursorX
                self.cursorState.y = cursorY
                self.cursorState.enabled = true
            }
        } else {
            if (cursorState.enabled) {
                notcurses_cursor_disable(plane.parentPlane!.notcurses!.pointer)
                cursorState.enabled = false
            }
            secondLine = await CommandInput.shared.getLastCommandOutput()
        }
        if secondLine.count < self.width {
            secondLine += String(
                repeating: " ",
                count: Int(self.width) - secondLine.count
            )
        } else if UI.mode == .command {
            secondLine = String(
                secondLine.dropFirst(secondLine.count - Int(self.width))
            )
        }

        guard let nowPlaying = Player.shared.nowPlaying else {
            if size == .default || size == .plus || size == .mega {
                if Int(self.width) - firstLineLeft.count > 0 {
                    firstLineLeft += String(
                        repeating: " ",
                        count: Int(self.width) - firstLineLeft.count
                    )
                }
                firstLineRight += "--:--/--:--"
            } else {
                firstLineLeft += String(
                    repeating: " ",
                    count: Int(self.width) - firstLineLeft.count
                )
            }
            printSections(
                firstLineLeft: firstLineLeft,
                firstLineRight: firstLineRight,
                secondLine: secondLine
            )
            return
        }

        if let nowPlaying = nowPlaying as? Song {
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

        }

        guard self.width > firstLineLeft.count else {
            output.putString(firstLineLeft, at: (0, 0))
            return
        }

        firstLineLeft.append(
            String(repeating: " ", count: Int(self.width) - firstLineLeft.count)
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
        output.putString(firstLineLeft, at: (0, 0))
        output.putString(
            firstLineRight,
            at: (Int32(self.width) - Int32(firstLineRight.count), 0)
        )
        output.putString(secondLine, at: (0, 1))
    }

    public func onResize() {
        self.width = plane.parentPlane!.width
    }

}

public enum YatoroSize {
    case nano
    case mini
    case `default`
    case plus
    case mega
}
