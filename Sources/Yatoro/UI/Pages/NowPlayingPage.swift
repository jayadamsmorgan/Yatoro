import Foundation
import Logging
import MusicKit

public actor NowPlayingPage: Page {

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
        state: PageState
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
                )
            )
        else {
            return nil
        }
        self.plane = plane
    }

    public func render() async {
        if currentSong == nil {
            self.currentSong = player.nowPlaying
        }
        if currentSong?.id != player.nowPlaying?.id {
            self.currentSong = player.nowPlaying
            logger?.debug("Player page erase triggered.")
        }
        plane.erase()

        plane.windowBorder(name: "Now Playing:", state: state)

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
