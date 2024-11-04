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
    private let artistLeftPlane: Plane
    private let artistRightPlane: Plane
    private let songLeftPlane: Plane
    private let songRightPlane: Plane
    private let albumLeftPlane: Plane
    private let albumRightPlane: Plane
    private let currentTimePlane: Plane
    private let durationPlane: Plane

    private var artworkPlane: Plane
    private var artworkVisual: Visual?
    private let artworkPixelWidth: UInt32
    private let artworkPixelHeight: UInt32

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
        processArtwork()
    }

    public func getMinDimensions() async -> (width: UInt32, height: UInt32) { (23, 11) }

    public func getMaxDimensions() async -> (width: UInt32, height: UInt32)? { nil }

    public func getPageState() async -> PageState { self.state }

    public init?(
        stdPlane: Plane,
        uiConfig: Config.UIConfig,
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

        let colorConfig = uiConfig.colors.nowPlaying
        self.artworkPixelWidth = uiConfig.artwork.width
        self.artworkPixelHeight = uiConfig.artwork.height

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
            let artistLeftPlane = Plane(
                in: plane,
                state: .init(
                    absX: 2,
                    absY: 2,
                    width: 7,
                    height: 1
                ),
                debugID: "NP_ARL"
            )
        else {
            return nil
        }
        artistLeftPlane.backgroundColor = colorConfig.artistLeft.background
        artistLeftPlane.foregroundColor = colorConfig.artistLeft.foreground
        artistLeftPlane.putString("Artist:", at: (0, 0))
        self.artistLeftPlane = artistLeftPlane

        guard
            let artistRightPlane = Plane(
                in: plane,
                state: .init(
                    absX: 2,
                    absY: 4,
                    width: 1,
                    height: 1
                ),
                debugID: "NP_ARR"
            )
        else {
            return nil
        }
        artistRightPlane.backgroundColor = colorConfig.artistRight.background
        artistRightPlane.foregroundColor = colorConfig.artistRight.foreground
        self.artistRightPlane = artistRightPlane

        guard
            let songLeftPlane = Plane(
                in: plane,
                state: .init(
                    absX: 2,
                    absY: 3,
                    width: 5,
                    height: 1
                ),
                debugID: "NP_SL"
            )
        else {
            return nil
        }
        songLeftPlane.backgroundColor = colorConfig.songLeft.background
        songLeftPlane.foregroundColor = colorConfig.songLeft.foreground
        songLeftPlane.putString("Song: ", at: (0, 0))
        self.songLeftPlane = songLeftPlane

        guard
            let songRightPlane = Plane(
                in: plane,
                state: .init(
                    absX: 2,
                    absY: 4,
                    width: 1,
                    height: 1
                ),
                debugID: "NP_SR"
            )
        else {
            return nil
        }
        songRightPlane.backgroundColor = colorConfig.songRight.background
        songRightPlane.foregroundColor = colorConfig.songRight.foreground
        self.songRightPlane = songRightPlane

        guard
            let albumRightPlane = Plane(
                in: plane,
                state: .init(
                    absX: 2,
                    absY: 4,
                    width: 1,
                    height: 1
                ),
                debugID: "NP_ALR"
            )
        else {
            return nil
        }
        albumRightPlane.backgroundColor = colorConfig.albumRight.background
        albumRightPlane.foregroundColor = colorConfig.albumRight.foreground
        self.albumRightPlane = albumRightPlane

        guard
            let currentTimePlane = Plane(
                in: plane,
                state: .init(
                    absX: 2,
                    absY: 4,
                    width: 5,
                    height: 1
                ),
                debugID: "NP_CT"
            )
        else {
            return nil
        }
        currentTimePlane.backgroundColor = colorConfig.currentTime.background
        currentTimePlane.foregroundColor = colorConfig.currentTime.foreground
        self.currentTimePlane = currentTimePlane

        guard
            let durationPlane = Plane(
                in: plane,
                state: .init(
                    absX: 2,
                    absY: 4,
                    width: 5,
                    height: 1
                ),
                debugID: "NP_TD"
            )
        else {
            return nil
        }
        durationPlane.backgroundColor = colorConfig.duration.background
        durationPlane.foregroundColor = colorConfig.duration.foreground
        self.durationPlane = durationPlane

        guard
            let artworkPlane = Plane(
                in: plane,
                state: .init(absX: 2, absY: 4, width: 1, height: 1),
                debugID: "NP_ART"
            )
        else {
            return nil
        }
        self.artworkPlane = artworkPlane

        guard
            let albumLeftPlane = Plane(
                in: plane,
                state: .init(
                    absX: 2,
                    absY: 4,
                    width: 6,
                    height: 1
                ),
                debugID: "NP_ALL"
            )
        else {
            return nil
        }
        albumLeftPlane.backgroundColor = colorConfig.albumLeft.background
        albumLeftPlane.foregroundColor = colorConfig.albumLeft.foreground
        albumLeftPlane.putString("Album:", at: (0, 0))
        self.albumLeftPlane = albumLeftPlane

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

    func processArtwork() {
        guard let currentSong else {
            self.artworkVisual?.destroy()
            self.artworkPlane.updateByPageState(
                .init(
                    absX: 2,
                    absY: 4,
                    width: 1,
                    height: 1
                )
            )
            return
        }
        if let url = currentSong.artwork?.url(
            width: Int(self.artworkPixelWidth),
            height: Int(self.artworkPixelHeight)
        ) {
            downloadImageAndConvertToRGBA(
                url: url,
                width: Int(self.artworkPixelWidth),
                heigth: Int(self.artworkPixelHeight)
            ) { pixelArray in
                if let pixelArray = pixelArray {
                    await logger?.debug(
                        "Now Playing: Successfully obtained artwork RGBA byte array with count: \(pixelArray.count)"
                    )
                    Task { @MainActor in
                        self.handleArtwork(pixelArray: pixelArray)
                    }
                } else {
                    await logger?.error("Now Playing: Failed to get artwork RGBA byte array.")
                }
            }
        }
    }

    func handleArtwork(pixelArray: [UInt8]) {
        let artworkPlaneWidth = min(self.state.width / 2, self.state.height - 3)
        let artworkPlaneHeight = artworkPlaneWidth / 2 - 1
        if artworkPlaneHeight > self.state.height - 12 {
            self.artworkVisual?.destroy()
            self.artworkPlane.updateByPageState(
                .init(
                    absX: 2,
                    absY: 4,
                    width: 1,
                    height: 1
                )
            )
            return
        }
        self.artworkPlane.updateByPageState(
            .init(
                absX: Int32(self.state.width / 2 - artworkPlaneWidth / 2),
                absY: Int32(self.state.height / 2 - artworkPlaneHeight / 2),
                width: artworkPlaneWidth,
                height: artworkPlaneHeight
            )
        )
        self.artworkVisual?.destroy()
        self.artworkVisual = Visual(
            in: UI.notcurses!,
            width: Int32(self.artworkPixelWidth),
            height: Int32(self.artworkPixelHeight),
            from: pixelArray,
            for: self.artworkPlane
        )
        self.artworkVisual?.render()
    }

    func updateSongDesc() {
        if currentSong == nil || currentSong?.id != player.nowPlaying?.id {
            self.currentSong = player.nowPlaying
            Task {
                processArtwork()
            }
        }
        guard let currentSong else {
            self.artistRightPlane.updateByPageState(.init(absX: 2, absY: 4, width: 1, height: 1))
            self.songRightPlane.updateByPageState(.init(absX: 2, absY: 4, width: 1, height: 1))
            self.albumRightPlane.updateByPageState(.init(absX: 2, absY: 4, width: 1, height: 1))
            self.currentTimePlane.updateByPageState(.init(absX: 2, absY: 4, width: 1, height: 1))
            self.durationPlane.updateByPageState(.init(absX: 2, absY: 4, width: 1, height: 1))
            self.artworkPlane.updateByPageState(.init(absX: 2, absY: 4, width: 1, height: 1))
            return
        }
        var width = min(UInt32(currentSong.artistName.count), self.state.width - 11)
        self.artistRightPlane.erase()
        self.artistRightPlane.updateByPageState(.init(absX: 10, absY: 2, width: width, height: 1))
        self.artistRightPlane.putString(currentSong.artistName, at: (0, 0))
        width = min(UInt32(currentSong.title.count), self.state.width - 11)
        self.songRightPlane.erase()
        self.songRightPlane.updateByPageState(.init(absX: 10, absY: 3, width: width, height: 1))
        self.songRightPlane.putString(currentSong.title, at: (0, 0))
        width = min(UInt32(currentSong.albumTitle?.count ?? 3), self.state.width - 11)
        self.albumRightPlane.erase()
        self.albumRightPlane.updateByPageState(.init(absX: 10, absY: 4, width: width, height: 1))
        self.albumRightPlane.putString(currentSong.albumTitle ?? "nil", at: (0, 0))

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
        currentTimePlane.updateByPageState(
            .init(absX: currentTimePositionX + 1, absY: currentTimePositionY + 1, width: 5, height: 1)
        )
        currentTimePlane.putString(currentTime.toMMSS(), at: (0, 0))
        durationPlane.updateByPageState(
            .init(absX: durationPositionX + 1, absY: durationPositionY + 1, width: 5, height: 1)
        )
        if let duration = currentSong.duration {
            durationPlane.putString(duration.toMMSS(), at: (0, 0))
        } else {
            durationPlane.putString("--:--", at: (0, 0))
        }
    }

    public func render() async {

        updateControls()

        updateSongDesc()

    }

}
