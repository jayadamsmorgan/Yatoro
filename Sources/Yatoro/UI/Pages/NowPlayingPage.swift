import Foundation
import Logging
import MusicKit
import SwiftNotCurses

@MainActor
public class NowPlayingPage: Page {

    private let player: Player = Player.shared

    private let plane: Plane

    private var state: PageState

    private var currentSong: Song?

    public func onResize(newPageState: PageState) async {
        self.state = newPageState
        plane.updateByPageState(state)
        plane.erase()
    }

    public func getMinDimensions() async -> (width: UInt32, height: UInt32) { (23, 13) }

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
        plane.backgroundColor = colorConfig.page.background
        plane.foregroundColor = colorConfig.page.foreground

        self.currentSong = player.nowPlaying
    }

    public func render() async {
        if currentSong == nil || currentSong?.id != player.nowPlaying?.id {
            self.currentSong = player.nowPlaying
        }
        plane.blank()

        plane.windowBorder(name: "Now Playing:", width: state.width, height: state.height)

        plane.putString(
            String(repeating: "─", count: Int(state.width - 4)),
            at: (2, Int32(state.height) - 4)
        )

        let position = calculateControlsPosition()
        if player.status == .playing {
            plane.putString(
                "◀◀   ⏸   ▶▶",
                at: (position, Int32(state.height) - 3)
            )
        } else {
            plane.putString(
                "◀◀   ▶   ▶▶",
                at: (position, Int32(state.height) - 3)
            )
        }

        guard let currentSong else { return }

        plane.putString(
            "station/playlist: \(currentSong.station?.name ?? "none")",
            at: (2, 3)
        )  // TODO: playlist recognition
        plane.putString(
            "artist: \(currentSong.artistName)",
            at: (2, 4)
        )
        plane.putString(
            "song: \(currentSong.title)",
            at: (2, 5)
        )
        plane.putString(
            "album: \(currentSong.albumTitle ?? "none")",
            at: (2, 6)
        )
        let currentPlaybackTime = player.player.playbackTime
        if let duration = currentSong.duration {
            plane.putString(
                "time: \(currentPlaybackTime.toMMSS()) / \(duration.toMMSS())",
                at: (2, 8)
            )
            let pos = calculatePointerPosition(
                playbackTime: duration,
                currentPlaybackTime: currentPlaybackTime,
                length: state.width - 4
            )
            plane.putString(
                "♦",
                at: (pos + 2, Int32(state.height) - 4)
            )
        } else {
            plane.putString(
                "time: \(currentPlaybackTime) / --:--",
                at: (2, Int32(state.height) - 4)
            )
        }
    }

    private func calculatePointerPosition(
        playbackTime: TimeInterval,
        currentPlaybackTime: TimeInterval,
        length: UInt32
    ) -> Int32 {
        let result = currentPlaybackTime / playbackTime * Double(length)
        return Int32(floor(result))
    }

    private func calculateControlsPosition() -> Int32 {
        let result = (state.width / 2) - 6
        return Int32(result)
    }

}
