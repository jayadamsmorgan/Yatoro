import Foundation
import Logging
import MusicKit
import notcurses

public actor NowPlayingPage: Page {

    private let player: Player = Player.shared

    private let output: Output

    private let plane: Plane
    private let logger: Logger?

    private var state: PageState

    private var currentSong: MusicItem?

    public func onResize(newPageState: PageState) async {
        self.state = newPageState
        ncplane_move_yx(plane.ncplane, state.absY, state.absX)
        ncplane_resize_simple(plane.ncplane, state.height, state.width)
        ncplane_erase(plane.ncplane)
    }

    public func getMinDimensions() async -> (width: UInt32, height: UInt32) {
        (23, 13)
    }

    public func getMaxDimensions() async -> (width: UInt32, height: UInt32)? {
        nil
    }

    public func getPageState() async -> PageState {
        self.state
    }

    public init?(
        stdPlane: Plane,
        state: PageState,
        logger: Logger?
    ) {
        self.state = state
        guard
            let plane = Plane(
                in: stdPlane,
                opts: .init(
                    x: state.absX,
                    y: state.absY,
                    width: state.width,
                    height: state.height,
                    debugID: "PLAYER_PAGE"
                ),
                logger: logger
            )
        else {
            return nil
        }
        self.plane = plane
        self.logger = logger
        self.output = .init(plane: plane)
        ncplane_set_bg_rgb8(plane.ncplane, 255, 0, 255)
    }

    public func render() async {
        if currentSong == nil {
            self.currentSong = player.nowPlaying
        }
        if currentSong?.id != player.nowPlaying?.id {
            self.currentSong = player.nowPlaying
            logger?.debug("Player page erase triggered.")
            ncplane_erase(self.plane.ncplane)
        }
        if let currentSong = currentSong as? Song {

            output.putString(
                "station/playlist: \(currentSong.station?.name ?? "none")",
                at: (0, 1)
            )  // TODO: playlist recognition
            output.putString(
                "artist: \(currentSong.artistName)",
                at: (0, 2)
            )
            output.putString(
                "song: \(currentSong.title)",
                at: (0, 3)
            )
            output.putString(
                "album: \(currentSong.albumTitle ?? "none")",
                at: (0, 4)
            )
            // output.putString(
            //     "up_next: \(player.upNext != nil ? (player.upNext!.title + " - " + player.upNext!.artistName) : "none")",
            //     at: (0, 5)
            // )
            output.putString(
                String(repeating: "─", count: Int(state.width)),
                at: (0, 11)
            )
            let currentPlaybackTime = player.player.playbackTime
            if let duration = currentSong.duration {
                output.putString(
                    "time: \(currentPlaybackTime.toMMSS()) / \(duration.toMMSS())",
                    at: (0, 6)
                )
                let pos = calculatePointerPosition(
                    playbackTime: duration,
                    currentPlaybackTime: currentPlaybackTime,
                    length: Int32(state.width)
                )
                output.putString("♦", at: (pos, 11))
            } else {
                output.putString(
                    "time: \(currentPlaybackTime) / --:--",
                    at: (0, 6)
                )
            }
        }
        let position = calculateControlsPosition()
        if player.status == .playing {
            output.putString("◀◀   ⏸   ▶▶", at: (position, 12))
        } else {
            output.putString("◀◀   ▶   ▶▶", at: (position, 12))
        }
    }

    private func calculatePointerPosition(
        playbackTime: TimeInterval,
        currentPlaybackTime: TimeInterval,
        length: Int32
    ) -> Int32 {
        let result = currentPlaybackTime / playbackTime * Double(length)
        return Int32(floor(result))
    }

    private func calculateControlsPosition() -> Int32 {
        let result = (state.width / 2) - 6
        return Int32(result)
    }

}
