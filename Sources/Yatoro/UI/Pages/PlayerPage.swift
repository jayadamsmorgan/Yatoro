import Foundation
import Logging
import MusicKit
import notcurses

public class PlayerPage: Page {

    /*

    station/playlist: morning
    artist: bushido zho
    song: vodila
    album: vodila
    upNext: PHARAOH - 5 минут на
    time: 0:51 / 3:05

    ⠁⠈⠉⠂  ⠐⠑⠘⠙⠒⠓⠚⠛⠄ ⠌⠍⠆⠇ ⠔⠕⠜⠝⠖
    ⡀⡁⡈⡉⡂ ⡊⡋⡐⡑⡘⡙⡒⡓⡚⡛⡄⡅⡌⡍ ⡇⡎⡏⡔⡕⡜⡝
    ⢀⢁⢈⢉⢂⢃⢊⢋⢐⢑⢘⢙⢒⢓⢚⢛⢄⢅⢌⢍⢆⢇⢎⢏⢔⢕⢜⢝
    ────────♦───────────────────
            ◀◀   ⏸   ▶▶

    minWidth: 28, minHeight: 12
    */

    private let player: Player = Player.shared

    private let output: Output

    public var plane: Plane
    public var logger: Logger?

    public let width: UInt32 = 28
    public let height: UInt32 = 13

    var currentSong: Song?

    public init?(stdPlane: Plane, logger: Logger?) {
        self.plane = stdPlane
        guard
            let plane = Plane(
                in: stdPlane,
                opts: .init(
                    x: 0,
                    y: 0,
                    width: width,
                    height: height,
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

    }

    public func render() {
        if currentSong == nil {
            self.currentSong = player.nowPlaying
        }
        if currentSong?.id != player.nowPlaying?.id {
            self.currentSong = player.nowPlaying
            logger?.debug("Player page erase triggered.")
            ncplane_erase(self.plane.ncplane)
        }
        output.putString("station/playlist: \(currentSong?.station?.name ?? "none")", at: (0, 1))  // TODO: playlist recognition
        output.putString("artist: \(currentSong?.artistName ?? "none")", at: (0, 2))
        output.putString("song: \(currentSong?.title ?? "none")", at: (0, 3))
        output.putString("album: \(currentSong?.albumTitle ?? "none")", at: (0, 4))
        output.putString(
            "up_next: \(player.upNext != nil ? (player.upNext!.title + " - " + player.upNext!.artistName) : "none")",
            at: (0, 5)
        )
        output.putString("────────────────────────────", at: (0, 11))
        if let nowPlaying = currentSong {
            let currentPlaybackTime = player.player.playbackTime
            if let duration = nowPlaying.duration {
                output.putString(
                    "time: \(currentPlaybackTime.toMMSS()) / \(duration.toMMSS())",
                    at: (0, 6)
                )
                let pos = calculatePointerPosition(
                    playbackTime: duration,
                    currentPlaybackTime: currentPlaybackTime,
                    length: Int32(self.width)
                )
                output.putString("♦", at: (pos, 11))
            } else {
                output.putString(
                    "time: \(currentPlaybackTime) / --:--",
                    at: (0, 6)
                )
            }
        } else {
            output.putString("time: none", at: (0, 6))
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
        return Int32(result.rounded())
    }

    private func calculateControlsPosition() -> Int32 {
        let result = (self.width / 2) - 6
        return Int32(result)
    }

    public func onResize() {

    }

}

extension TimeInterval {
    func toMMSS() -> String {
        let time = Int(self)
        let minutes = (time / 60) % 60
        let seconds = time % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
