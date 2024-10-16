import Foundation
import Logging
import MusicKit
import SwiftNotCurses

@MainActor
public class NowPlayingPage: Page {

    private let player: Player = Player.shared

    private let plane: Plane

    private let pagePlane: Plane
    private let pageNamePlane: Plane
    private let borderPlane: Plane
    private let sliderPlane: Plane
    private let sliderKnobPlane: Plane
    private let controlsPlane: Plane
    private let itemDescLeftPlane: Plane
    private let itemDescRightPlane: Plane

    private var state: PageState

    private var lastPlayerStatus: MusicPlayer.PlaybackStatus?

    private var currentSong: Song?

    public func onResize(newPageState: PageState) async {
        self.state = newPageState
        plane.updateByPageState(state)
        pagePlane.updateByPageState(
            .init(
                absX: 1,
                absY: 1,
                width: state.width - 2,
                height: state.height - 2
            )
        )
        pagePlane.blank()
        borderPlane.updateByPageState(
            .init(
                absX: 0,
                absY: 0,
                width: state.width,
                height: state.height
            )
        )
        borderPlane.erase()
        borderPlane.windowBorder(width: state.width, height: state.height)
        itemDescLeftPlane.updateByPageState(
            .init(
                absX: 2,
                absY: 2,
                width: 8,
                height: 3
            )
        )
        let sliderWidth = UInt32(Double(state.width) / 1.5)
        sliderPlane.updateByPageState(
            .init(
                absX: Int32(state.width) / 6,
                absY: Int32(state.height) - 4,
                width: sliderWidth,
                height: 1
            )
        )
        sliderPlane.putString(
            String(repeating: "─", count: Int(sliderPlane.width)),
            at: (0, 0)
        )
        sliderKnobPlane.updateByPageState(
            .init(
                absX: Int32(state.width) / 6,
                absY: Int32(state.height) - 4,
                width: 1,
                height: 1
            )
        )
        controlsPlane.updateByPageState(
            .init(
                absX: Int32(state.width) / 2 - 6,
                absY: Int32(state.height) - 3,
                width: 11,
                height: 1
            )
        )
    }

    public func getMinDimensions() async -> (width: UInt32, height: UInt32) { (23, 11) }

    public func getMaxDimensions() async -> (width: UInt32, height: UInt32)? { nil }

    public func getPageState() async -> PageState { self.state }

    public init?(
        stdPlane: Plane,
        colorConfig: Config.UIConfig.Colors.NowPlaying,
        state: PageState
    ) {
        self.state = state
        guard
            let plane = Plane(
                in: stdPlane,
                state: state,
                debugID: "NOW_PLAYING_PAGE"
            )
        else {
            return nil
        }
        self.plane = plane

        guard
            let borderPlane = Plane(
                in: plane,
                state: .init(
                    absX: 0,
                    absY: 0,
                    width: state.width,
                    height: state.height
                ),
                debugID: "NP_BORDER"
            )
        else {
            return nil
        }
        borderPlane.backgroundColor = colorConfig.border.background
        borderPlane.foregroundColor = colorConfig.border.foreground
        borderPlane.windowBorder(width: state.width, height: state.height)
        self.borderPlane = borderPlane

        guard
            let pageNamePlane = Plane(
                in: plane,
                state: .init(
                    absX: 2,
                    absY: 0,
                    width: 11,
                    height: 1
                ),
                debugID: "NP_NAME"
            )
        else {
            return nil
        }
        pageNamePlane.backgroundColor = colorConfig.pageName.background
        pageNamePlane.foregroundColor = colorConfig.pageName.foreground
        pageNamePlane.putString("Now Playing", at: (0, 0))
        self.pageNamePlane = pageNamePlane

        guard
            let pagePlane = Plane(
                in: plane,
                state: .init(
                    absX: 1,
                    absY: 1,
                    width: state.width - 2,
                    height: state.width - 2
                ),
                debugID: "NP_PAGE"
            )
        else {
            return nil
        }
        pagePlane.backgroundColor = colorConfig.page.background
        pagePlane.foregroundColor = colorConfig.page.foreground
        pagePlane.blank()
        self.pagePlane = pagePlane

        guard
            let sliderPlane = Plane(
                in: plane,
                state: .init(
                    absX: Int32(state.width) / 4,
                    absY: Int32(state.height) - 4,
                    width: state.width / 2,
                    height: 1
                ),
                debugID: "NP_SLIDER"
            )
        else {
            return nil
        }
        sliderPlane.backgroundColor = colorConfig.slider.background
        sliderPlane.foregroundColor = colorConfig.slider.foreground
        self.sliderPlane = sliderPlane

        guard
            let sliderKnobPlane = Plane(
                in: plane,
                state: .init(
                    absX: Int32(state.width) / 6,
                    absY: Int32(state.height) - 4,
                    width: 1,
                    height: 1
                ),
                debugID: "NP_SLIDER_KNOB"
            )
        else {
            return nil
        }
        sliderKnobPlane.backgroundColor = colorConfig.sliderKnob.background
        sliderKnobPlane.foregroundColor = colorConfig.sliderKnob.foreground
        sliderKnobPlane.putString("♦", at: (0, 0))
        self.sliderKnobPlane = sliderKnobPlane

        guard
            let controlsPlane = Plane(
                in: plane,
                state: .init(
                    absX: Int32(state.width) / 2 - 6,
                    absY: Int32(state.height) - 3,
                    width: 11,
                    height: 1
                ),
                debugID: "NP_CONTROLS"
            )
        else {
            return nil
        }
        controlsPlane.backgroundColor = colorConfig.controls.background
        controlsPlane.foregroundColor = colorConfig.controls.foreground
        self.controlsPlane = controlsPlane

        guard
            let itemDescRightPlane = Plane(
                in: plane,
                state: .init(
                    absX: 2,
                    absY: 2,
                    width: 1,
                    height: 3
                ),
                debugID: "NP_DESC_RIGHT"
            )
        else {
            return nil
        }
        itemDescRightPlane.backgroundColor = colorConfig.itemDescriptionRight.background
        itemDescRightPlane.foregroundColor = colorConfig.itemDescriptionRight.foreground
        self.itemDescRightPlane = itemDescRightPlane

        guard
            let itemDescLeftPlane = Plane(
                in: plane,
                state: .init(
                    absX: 2,
                    absY: 2,
                    width: 8,
                    height: 3
                ),
                debugID: "NP_DESC_LEFT"
            )
        else {
            return nil
        }
        itemDescLeftPlane.backgroundColor = colorConfig.itemDescriptionLeft.background
        itemDescLeftPlane.foregroundColor = colorConfig.itemDescriptionLeft.foreground
        itemDescLeftPlane.putString("Artist: ", at: (0, 0))
        itemDescLeftPlane.putString("Song:   ", at: (0, 1))
        itemDescLeftPlane.putString("Album:  ", at: (0, 2))
        self.itemDescLeftPlane = itemDescLeftPlane

        self.currentSong = player.nowPlaying
    }

    private func updateControls() {
        guard lastPlayerStatus != player.status else {
            return
        }
        lastPlayerStatus = player.status
        if lastPlayerStatus == .playing {
            controlsPlane.putString(
                "◀◀   ⏸   ▶▶",
                at: (0, 0)
            )
        } else {
            controlsPlane.putString(
                "◀◀   ▶   ▶▶",
                at: (0, 0)
            )
        }
    }

    func updateSongDesc() {
        if currentSong == nil || currentSong?.id != player.nowPlaying?.id {
            self.currentSong = player.nowPlaying
        }
        guard let currentSong else {
            self.itemDescRightPlane.updateByPageState(
                .init(
                    absX: 2,
                    absY: 2,
                    width: 1,
                    height: 1
                )
            )
            return
        }
        var width =
            max(
                (currentSong.albumTitle ?? "nil").count,
                currentSong.title.count,
                currentSong.artistName.count
            ) + 8
        width = min(width, Int(self.state.width) - 4)
        self.itemDescRightPlane.updateByPageState(
            .init(
                absX: 2,
                absY: 2,
                width: UInt32(width),
                height: 3
            )
        )
        self.itemDescRightPlane.blank()
        self.itemDescRightPlane.putString(currentSong.artistName, at: (8, 0))
        self.itemDescRightPlane.putString(currentSong.title, at: (8, 1))
        self.itemDescRightPlane.putString(currentSong.albumTitle ?? "nil", at: (8, 2))

        let currentTime = player.player.playbackTime
        let sliderPositionX = Int32(state.width) / 6
        let sliderPositionY = Int32(state.height) - 4
        let sliderWidth = Double(state.width) / 1.5

        let position: Double
        if let duration = currentSong.duration {
            position = sliderWidth * (currentTime / duration)
        } else {
            position = 0
        }
        let currentTimePositionX: Int32
        let currentTimePositionY: Int32
        let durationPositionX: Int32
        let durationPositionY: Int32
        if sliderPositionX < 9 {
            currentTimePositionX = sliderPositionX
            currentTimePositionY = sliderPositionY - 2
            durationPositionX = sliderPositionX + Int32(sliderWidth) - 7
            durationPositionY = currentTimePositionY
        } else {
            currentTimePositionX = sliderPositionX - 7
            currentTimePositionY = sliderPositionY - 1
            durationPositionX = sliderPositionX + Int32(sliderWidth)
            durationPositionY = currentTimePositionY
        }

        self.sliderKnobPlane.updateByPageState(
            .init(
                absX: sliderPositionX + Int32(position),
                absY: sliderPositionY,
                width: 1,
                height: 1
            )
        )
        pagePlane.putString(
            currentTime.toMMSS(),
            at: (currentTimePositionX, currentTimePositionY)
        )
        if let duration = currentSong.duration {
            pagePlane.putString(
                duration.toMMSS(),
                at: (
                    durationPositionX,
                    durationPositionY
                )
            )
        } else {
            pagePlane.putString(
                "--:--",
                at: (
                    durationPositionX,
                    durationPositionY
                )
            )
        }
    }

    public func render() async {

        updateControls()

        updateSongDesc()

    }

}
