import Logging
import MusicKit
import SwiftNotCurses

@MainActor
public class CommandPage: Page {

    private var stdPlane: Plane
    private let plane: Plane

    private var modePlane: Plane
    private var playStatusPlane: Plane
    private var timePlane: Plane
    private var inputPlane: Plane
    private var nowPlayingArtistPlane: Plane
    private var nowPlayingDashPlane: Plane
    private var nowPlayingTitlePlane: Plane

    private var completionsPlane: Plane
    private var completionSelectedPlane: Plane
    private var completionsCache: ArraySlice<String>
    private var completionTopIndex: Int
    private var completionSelected: Int

    private var modeNormalColor: Config.UIConfig.Colors.ColorPair
    private var modeCommandColor: Config.UIConfig.Colors.ColorPair

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
        plane.blank()

        inputPlane.updateByPageState(
            .init(
                absX: 0,
                absY: 1,
                width: state.width,
                height: 1
            )
        )

        switch size {
        case .default, .plus, .mega:
            timePlane.updateByPageState(
                .init(
                    absX: Int32(state.width) - 11,
                    absY: 0,
                    width: 11,
                    height: 1
                )
            )
        case .nano, .mini:
            timePlane.updateByPageState(
                .init(
                    absX: Int32(state.width) + 1,
                    absY: 0,
                    width: 11,
                    height: 1
                )
            )
        }

        completionsPlane.moveOnTopOfZStack()
    }

    public func getPageState() async -> PageState { self.state }

    public func getMinDimensions() async -> (width: UInt32, height: UInt32) { return (10, 2) }

    public func getMaxDimensions() async -> (width: UInt32, height: UInt32)? { nil }

    public init?(
        stdPlane: Plane,
        colorConfig: Config.UIConfig.Colors.CommandLine
    ) {
        self.state = .init(
            absX: 0,
            absY: Int32(stdPlane.height) - 2,
            width: stdPlane.width,
            height: 2
        )
        guard
            let plane = Plane(
                in: stdPlane,
                state: state,
                debugID: "COMMAND_PAGE"
            )
        else {
            return nil
        }
        plane.backgroundColor = colorConfig.page.background
        plane.foregroundColor = colorConfig.page.foreground
        plane.blank()
        self.plane = plane

        guard
            let inputPlane = Plane(
                in: plane,
                state: .init(
                    absX: 0,
                    absY: 1,
                    width: state.width,
                    height: 1
                ),
                debugID: "CMD_INPUT"
            )
        else {
            return nil
        }
        inputPlane.backgroundColor = colorConfig.input.background
        inputPlane.foregroundColor = colorConfig.input.foreground
        self.inputPlane = inputPlane

        guard
            let nowPlayingArtistPlane = Plane(
                in: plane,
                state: .init(
                    absX: -5,
                    absY: 0,
                    width: 1,
                    height: 1
                ),
                debugID: "CMD_NP_ARTIST"
            )
        else {
            return nil
        }
        nowPlayingArtistPlane.backgroundColor = colorConfig.nowPlayingArtist.background
        nowPlayingArtistPlane.foregroundColor = colorConfig.nowPlayingArtist.foreground
        self.nowPlayingArtistPlane = nowPlayingArtistPlane

        guard
            let nowPlayingDashPlane = Plane(
                in: plane,
                state: .init(
                    absX: -4,
                    absY: 0,
                    width: 1,
                    height: 1
                ),
                debugID: "CMD_NP_DASH"
            )
        else {
            return nil
        }
        nowPlayingDashPlane.backgroundColor = colorConfig.nowPlayingDash.background
        nowPlayingDashPlane.foregroundColor = colorConfig.nowPlayingDash.foreground
        self.nowPlayingDashPlane = nowPlayingDashPlane

        guard
            let nowPlayingTitlePlane = Plane(
                in: plane,
                state: .init(
                    absX: -3,
                    absY: 0,
                    width: 1,
                    height: 1
                ),
                debugID: "CMD_NP_TITLE"
            )
        else {
            return nil
        }
        nowPlayingTitlePlane.backgroundColor = colorConfig.nowPlayingTitle.background
        nowPlayingTitlePlane.foregroundColor = colorConfig.nowPlayingTitle.foreground
        self.nowPlayingTitlePlane = nowPlayingTitlePlane

        guard
            let timePlane = Plane(
                in: plane,
                state: .init(
                    absX: Int32(state.width) - 11,
                    absY: 0,
                    width: 11,
                    height: 1
                ),
                debugID: "CMD_TIME"
            )
        else {
            return nil
        }
        timePlane.backgroundColor = colorConfig.time.background
        timePlane.foregroundColor = colorConfig.time.foreground
        self.timePlane = timePlane

        guard
            let modePlane = Plane(
                in: plane,
                state: .init(
                    absX: 0,
                    absY: 0,
                    width: 8,
                    height: 1
                ),
                debugID: "CMD_SS"
            )
        else {
            return nil
        }
        self.modeNormalColor = colorConfig.modeNormal
        self.modeCommandColor = colorConfig.modeCommand
        self.modePlane = modePlane

        guard
            let playStatusPlane = Plane(
                in: plane,
                state: .init(
                    absX: 7,
                    absY: 0,
                    width: 10,
                    height: 1
                ),
                debugID: "CMD_PS"
            )
        else {
            return nil
        }
        playStatusPlane.backgroundColor = colorConfig.playStatus.background
        playStatusPlane.foregroundColor = colorConfig.playStatus.foreground
        self.playStatusPlane = playStatusPlane

        guard
            let completionsPlane = Plane(
                in: stdPlane,
                state: .init(
                    absX: -1,
                    absY: state.absY,
                    width: 1,
                    height: 1
                ),
                debugID: "CMD_CMP"
            )
        else {
            return nil
        }
        self.completionsPlane = completionsPlane

        guard
            let completionSelectedPlane = Plane(
                in: completionsPlane,
                state: .init(
                    absX: 0,
                    absY: 0,
                    width: 1,
                    height: 1
                ),
                debugID: "CMD_CMP_SEL"
            )
        else {
            return nil
        }
        self.completionSelectedPlane = completionSelectedPlane
        self.completionTopIndex = 0
        self.completionSelected = 0
        self.completionsCache = []

        self.stdPlane = stdPlane
    }

    func renderMode() {
        modePlane.erase()

        switch UI.mode {
        case .normal:
            modePlane.backgroundColor = self.modeNormalColor.background
            modePlane.foregroundColor = self.modeNormalColor.foreground
        case .command:
            modePlane.backgroundColor = self.modeCommandColor.background
            modePlane.foregroundColor = self.modeCommandColor.foreground
        }

        switch size {
        case .nano, .mini:
            modePlane.updateByPageState(.init(absX: 0, absY: 0, width: 1, height: 1))
            switch UI.mode {
            case .normal:
                modePlane.putString("N", at: (0, 0))
            case .command:
                modePlane.putString("C", at: (0, 0))
            }
        case .default:
            switch UI.mode {
            case .normal:
                modePlane.updateByPageState(.init(absX: 0, absY: 0, width: 4, height: 1))
                modePlane.putString("NRML", at: (0, 0))
            case .command:
                modePlane.updateByPageState(.init(absX: 0, absY: 0, width: 3, height: 1))
                modePlane.putString("CMD", at: (0, 0))
            }
        case .plus, .mega:
            switch UI.mode {
            case .normal:
                modePlane.updateByPageState(.init(absX: 0, absY: 0, width: 6, height: 1))
                modePlane.putString("NORMAL", at: (0, 0))
            case .command:
                modePlane.updateByPageState(.init(absX: 0, absY: 0, width: 7, height: 1))
                modePlane.putString("COMMAND", at: (0, 0))
            }
        }
    }

    func renderPlayerStatus() {
        playStatusPlane.erase()

        let x = Int32(modePlane.width) + 2

        switch Player.shared.status {
        case .stopped:
            switch size {
            case .nano, .mini, .default:
                playStatusPlane.updateByPageState(.init(absX: x, absY: 0, width: 1, height: 1))
                playStatusPlane.putString("#", at: (0, 0))
            case .plus, .mega:
                playStatusPlane.updateByPageState(.init(absX: x, absY: 0, width: 9, height: 1))
                playStatusPlane.putString("# Stopped", at: (0, 0))
            }
        case .playing:
            switch size {
            case .nano, .mini, .default:
                playStatusPlane.updateByPageState(.init(absX: x, absY: 0, width: 1, height: 1))
                playStatusPlane.putString("▶", at: (0, 0))
            case .plus, .mega:
                playStatusPlane.updateByPageState(.init(absX: x, absY: 0, width: 9, height: 1))
                playStatusPlane.putString("▶ Playing", at: (0, 0))
            }
        case .paused:
            switch size {
            case .nano, .mini, .default:
                playStatusPlane.updateByPageState(.init(absX: x, absY: 0, width: 1, height: 1))
                playStatusPlane.putString("⏸", at: (0, 0))
            case .plus, .mega:
                playStatusPlane.updateByPageState(.init(absX: x, absY: 0, width: 8, height: 1))
                playStatusPlane.putString("⏸ Paused", at: (0, 0))
            }
        case .interrupted:
            switch size {
            case .nano, .mini, .default:
                playStatusPlane.updateByPageState(.init(absX: x, absY: 0, width: 2, height: 1))
                playStatusPlane.putString("//", at: (0, 0))
            case .plus, .mega:
                playStatusPlane.updateByPageState(.init(absX: x, absY: 0, width: 14, height: 1))
                playStatusPlane.putString("// Interrupted", at: (0, 0))
            }
        case .seekingForward:
            switch size {
            case .nano, .mini, .default:
                playStatusPlane.updateByPageState(.init(absX: x, absY: 0, width: 2, height: 1))
                playStatusPlane.putString("▶▶", at: (0, 0))
            case .plus, .mega:
                playStatusPlane.updateByPageState(.init(absX: x, absY: 0, width: 10, height: 1))
                playStatusPlane.putString("▶▶ Seeking", at: (0, 0))
            }
        case .seekingBackward:
            switch size {
            case .nano, .mini, .default:
                playStatusPlane.updateByPageState(.init(absX: x, absY: 0, width: 2, height: 1))
                playStatusPlane.putString("◀◀", at: (0, 0))
            case .plus, .mega:
                playStatusPlane.updateByPageState(.init(absX: x, absY: 0, width: 10, height: 1))
                playStatusPlane.putString("◀◀ Seeking", at: (0, 0))
            }
        @unknown default:
            switch size {
            case .nano, .mini, .default:
                playStatusPlane.updateByPageState(.init(absX: x, absY: 0, width: 2, height: 1))
                playStatusPlane.putString("?", at: (0, 0))
            case .plus, .mega:
                playStatusPlane.updateByPageState(.init(absX: x, absY: 0, width: 9, height: 1))
                playStatusPlane.putString("? Unknown", at: (0, 0))
            }
        }
    }

    public func renderCompletions() async {
        guard InputQueue.shared.commandCompletionsActive else {
            self.completionsCache = []
            self.completionTopIndex = 0
            self.completionSelected = 0
            return
        }
        let completionsDisplayedAmount = min(
            Int(max(stdPlane.height - 5, 0)),
            InputQueue.shared.completionCommands.count
        )
        guard completionsDisplayedAmount != 0 else {
            return
        }
        guard completionTopIndex < completionsDisplayedAmount else {
            return
        }
        let completionsDisplayed = InputQueue.shared.completionCommands[
            completionTopIndex..<completionsDisplayedAmount
        ]
        if self.completionsCache != completionsDisplayed {
            self.completionsCache = completionsDisplayed
        }
        let completionsLengths = InputQueue.shared.completionCommands.map({ UInt32($0.count) })
        let maxCompletionLength = completionsLengths.max() ?? 1
        let yPos = state.absY - Int32(completionsDisplayedAmount)
        completionsPlane.updateByPageState(
            .init(
                absX: 0,
                absY: yPos,
                width: maxCompletionLength,
                height: UInt32(completionsDisplayedAmount)
            )
        )
    }

    public func renderCommandInput() async {
        inputPlane.blank()
        if (UI.mode == .command) {
            inputPlane.putString(":\(await CommandInput.shared.get())", at: (0, 0))
            let absolutePlanePositionY = state.absY
            let cursorY = absolutePlanePositionY + 1
            let cursorX =
                Int32(await CommandInput.shared.getCursorPosition()) + 1
            if (cursorState.x != cursorX || !cursorState.enabled) {
                logger?.trace("Cursor update")
                UI.notcurses?.enableCursor(at: (cursorX, cursorY))
                self.cursorState.x = cursorX
                self.cursorState.y = cursorY
                self.cursorState.enabled = true
            }
            await renderCompletions()
        } else {
            if (cursorState.enabled) {
                UI.notcurses?.disableCursor()
                cursorState.enabled = false
            }
            inputPlane.putString(await CommandInput.shared.getLastCommandOutput(), at: (0, 0))
        }
    }

    public func renderCurrentSong() {

        let x = Int32(playStatusPlane.width) + playStatusPlane.x + 2

        nowPlayingTitlePlane.erase()
        nowPlayingDashPlane.erase()
        nowPlayingArtistPlane.erase()

        guard let nowPlaying = Player.shared.nowPlaying else {
            return
        }

        switch size {
        case .nano, .mini:
            nowPlayingTitlePlane.updateByPageState(.init(absX: -5, absY: 0, width: 1, height: 1))
            nowPlayingDashPlane.updateByPageState(.init(absX: -4, absY: 0, width: 1, height: 1))
            nowPlayingArtistPlane.updateByPageState(.init(absX: -3, absY: 0, width: 1, height: 1))
        case .default:
            nowPlayingTitlePlane.updateByPageState(
                .init(
                    absX: x,
                    absY: 0,
                    width: UInt32(nowPlaying.title.count),
                    height: 1
                )
            )
            nowPlayingTitlePlane.putString(nowPlaying.title, at: (0, 0))
            nowPlayingDashPlane.updateByPageState(.init(absX: -4, absY: 0, width: 1, height: 1))
            nowPlayingArtistPlane.updateByPageState(.init(absX: -3, absY: 0, width: 1, height: 1))
        case .plus, .mega:
            nowPlayingArtistPlane.updateByPageState(
                .init(
                    absX: x,
                    absY: 0,
                    width: UInt32(nowPlaying.artistName.count),
                    height: 1
                )
            )
            nowPlayingArtistPlane.putString(nowPlaying.artistName, at: (0, 0))
            nowPlayingDashPlane.updateByPageState(
                .init(
                    absX: nowPlayingArtistPlane.x + Int32(nowPlayingArtistPlane.width) + 1,
                    absY: 0,
                    width: 1,
                    height: 1
                )
            )
            nowPlayingDashPlane.putString("-", at: (0, 0))

            nowPlayingTitlePlane.updateByPageState(
                .init(
                    absX: nowPlayingDashPlane.x + 2,
                    absY: 0,
                    width: UInt32(nowPlaying.title.count),
                    height: 1
                )
            )
            nowPlayingTitlePlane.putString(nowPlaying.title, at: (0, 0))
        }
    }

    func renderNowPlayingTime() {
        guard let nowPlaying = Player.shared.nowPlaying else {
            switch size {
            case .default, .plus, .mega:
                timePlane.putString("--:--/--:--", at: (0, 0))
            default:
                timePlane.erase()
            }
            return
        }
        let playbackTime = Player.shared.player.playbackTime.toMMSS()
        guard let duration = nowPlaying.duration?.toMMSS() else {
            switch size {
            case .default, .plus, .mega:
                timePlane.putString("\(playbackTime)/--:--", at: (0, 0))
            default:
                timePlane.erase()
            }
            return
        }
        switch size {
        case .default, .plus, .mega:
            timePlane.putString("\(playbackTime)/\(duration)", at: (0, 0))
        default: timePlane.erase()
        }
    }

    public func render() async {

        renderMode()

        renderPlayerStatus()

        renderCurrentSong()

        renderNowPlayingTime()

        await renderCommandInput()

    }
}
