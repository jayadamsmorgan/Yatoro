import AVFoundation
import Logging
import MediaPlayer
@preconcurrency import MusicKit

public typealias Player = AudioPlayerManager

public typealias LibraryTopResult = MusicLibrarySearchResponse.TopResult
public typealias CatalogTopResult = MusicCatalogSearchResponse.TopResult

extension CatalogTopResult: @retroactive MusicCatalogSearchable {}
extension LibraryTopResult: @retroactive MusicLibrarySearchable {}

public final class AudioPlayerManager: Sendable {

    @MainActor static let shared = AudioPlayerManager()

    public let player = ApplicationMusicPlayer.shared

    public var queue: ApplicationMusicPlayer.Queue.Entries {
        guard let currentEntry = player.queue.currentEntry else {
            return player.queue.entries
        }

        guard
            let currentPosition = player.queue.entries.firstIndex(
                where: { currentEntry.id == $0.id }
            )
        else {
            return player.queue.entries
        }

        let entries = ApplicationMusicPlayer.Queue.Entries(
            player.queue.entries[currentPosition...]
        )
        return entries

    }

    var nowPlaying: Song? {
        switch player.queue.currentEntry?.item {
        case .song(let song): return song
        default: return nil
        }
    }

    var upNext: Song? {
        if let currentEntry = player.queue.currentEntry {
            let index = player.queue.entries.index(
                after: player.queue.entries.firstIndex(of: currentEntry)!
            )
            switch player.queue.entries[index].item {
            case .song(let song): return song
            default: return nil
            }
        }
        return nil
    }

    public var status: ApplicationMusicPlayer.PlaybackStatus {
        player.state.playbackStatus
    }
}

// STARTUP
public extension AudioPlayerManager {

    func authorize() async {
        await logger?.trace("Sending music authorization request...")
        let authorizationStatus = await MusicAuthorization.request()
        guard authorizationStatus == .authorized else {
            await logger?.debug(
                "Music authorization not granted. Status: \(authorizationStatus.description)"
            )
            fatalError("Cannot authorize Apple Music request.")
        }
        await logger?.debug("Music authorization granted.")
    }

}

// PLAYBACK
public extension AudioPlayerManager {

    private func _play() async throws {
        await logger?.trace("Trying to play...")
        let playerStatus = player.state.playbackStatus
        await logger?.trace("Player status: \(playerStatus)")
        switch player.state.playbackStatus {
        case .paused:
            await logger?.trace("Trying to continue playing...")
            try await player.play()
            await logger?.trace("Player playing.")
            return
        case .playing:
            await logger?.debug("Player is already playing.")
            return
        case .stopped:
            try await player.play()
        case .interrupted:
            await logger?.critical("Something went wrong: Player status interrupted.")
            return
        case .seekingForward, .seekingBackward:
            await logger?.trace("Trying to stop seeking...")
            player.endSeeking()
            return
        @unknown default:
            await logger?.error("Unknown player status \(playerStatus).")
            return
        }
    }

    func play() async {
        do {
            try await _play()
        } catch {
            await logger?.error(
                "Error playing: \(error.localizedDescription) \(type(of: error))"
            )
        }
    }

    func pause() async {
        await logger?.trace("Trying to pause...")
        let playerStatus = player.state.playbackStatus
        await logger?.trace("Player status: \(playerStatus)")
        switch player.state.playbackStatus {
        case .paused:
            await logger?.debug("Player is already paused.")
            return
        case .playing:
            player.pause()
            await logger?.trace("Player paused.")
            return
        case .stopped:
            await logger?.error("Trying to pause stopped player.")
            return
        case .interrupted:
            await logger?.critical("Something went wrong: Player status interrupted.")
            return
        case .seekingForward, .seekingBackward:
            await logger?.trace("Trying to stop seeking...")
            player.endSeeking()
            player.pause()
            await logger?.trace("Player stopped seeking and paused.")
            return
        @unknown default:
            await logger?.error("Unknown player status \(playerStatus).")
            return
        }
    }

    func playPauseToggle() async {
        switch player.state.playbackStatus {
        case .paused:
            await self.play()
        case .playing:
            await self.pause()
        case .stopped:
            await self.play()
        default:
            return
        }
    }

    func restartSong() async {
        player.restartCurrentEntry()
    }

    func playNext() async {
        do {
            try await player.skipToNextEntry()
        } catch {
            await logger?.error("Failed to play next: \(error.localizedDescription)")
        }
    }

    func playPrevious() async {
        do {
            try await player.skipToPreviousEntry()
        } catch {
            await logger?.error(
                "Failed to play previous: \(error.localizedDescription)"
            )
        }
    }

    func clearQueue() async {
        player.queue.entries = []
    }

    func playLater<T>(
        _ item: T
    ) async
    where T: PlayableMusicItem {
        await addItemsToQueue(items: [item], at: .tail)
    }

    func playLater(
        _ item: any PlayableMusicItem
    ) async {
        switch item {
        case let item as Song:
            await addItemsToQueue(items: [item], at: .tail)
        case let item as Playlist:
            await addItemsToQueue(items: [item], at: .tail)
        case let item as Station:
            await addItemsToQueue(items: [item], at: .tail)
        // TODO: add more
        default: break
        }
    }

    func playLater<T>(
        _ items: MusicItemCollection<T>
    ) async
    where T: PlayableMusicItem {
        await addItemsToQueue(items: items, at: .tail)
    }

    func playLater(
        _ items: AnyPlayableMusicItemCollection
    ) async {
        switch items {
        case let items as MusicItemCollection<Song>:
            await addItemsToQueue(items: items, at: .tail)
        case let items as MusicItemCollection<Playlist>:
            await addItemsToQueue(items: items, at: .tail)
        case let items as MusicItemCollection<Station>:
            await addItemsToQueue(items: items, at: .tail)
        // TODO: add more
        default: break
        }
    }

    func playNext<T>(
        _ item: T
    ) async
    where T: PlayableMusicItem {
        await addItemsToQueue(items: [item], at: .afterCurrentEntry)
    }

    func playNext(
        _ item: any PlayableMusicItem
    ) async {
        switch item {
        case let item as Song:
            await addItemsToQueue(items: [item], at: .afterCurrentEntry)
        case let item as Playlist:
            await addItemsToQueue(items: [item], at: .afterCurrentEntry)
        case let item as Station:
            await addItemsToQueue(items: [item], at: .afterCurrentEntry)
        // TODO: add more
        default: break
        }
    }

    func playNext<T>(
        _ items: MusicItemCollection<T>
    ) async
    where T: PlayableMusicItem {
        await addItemsToQueue(items: items, at: .afterCurrentEntry)
    }

    func playNext(
        _ items: AnyPlayableMusicItemCollection
    ) async {
        switch items {
        case let items as MusicItemCollection<Song>:
            await addItemsToQueue(items: items, at: .afterCurrentEntry)
        case let items as MusicItemCollection<Playlist>:
            await addItemsToQueue(items: items, at: .afterCurrentEntry)
        case let items as MusicItemCollection<Station>:
            await addItemsToQueue(items: items, at: .afterCurrentEntry)
        // TODO: add more
        default: break
        }
    }

    func addItemsToQueue<T>(
        items: MusicItemCollection<T>,
        at position: ApplicationMusicPlayer.Queue.EntryInsertionPosition
    ) async
    where T: PlayableMusicItem {
        do {
            if player.queue.entries.isEmpty {
                player.queue = .init(for: items)
            } else {
                try await player.queue.insert(items, position: position)
            }
        } catch {
            await logger?.error(
                "Unable to add songs to player queue: \(error.localizedDescription)"
            )
            return
        }
        do {
            if !player.isPreparedToPlay {
                await logger?.trace("Preparing player...")
                try await player.prepareToPlay()
            }
        } catch {
            await logger?.critical("Unable to prepare player: \(error)")
        }
    }

    func setTime(
        seconds: Int,
        relative: Bool
    ) async {
        guard let nowPlaying else {
            await logger?.debug("Unable to set time for current song: Not playing")
            return
        }
        guard let nowPlayingDuration = nowPlaying.duration else {
            await logger?.debug(
                "Unable to set time for current song: Undefined duration"
            )
            return
        }
        if relative {
            if player.playbackTime + Double(seconds) < 0 {
                player.playbackTime = 0
            } else if player.playbackTime + Double(seconds) > nowPlayingDuration {
                player.playbackTime = nowPlayingDuration
            } else {
                player.playbackTime = player.playbackTime + Double(seconds)
            }
            await logger?.trace("Set time for current song: \(player.playbackTime)")
            return
        }
        guard seconds >= 0 else {
            await logger?.debug(
                "Unable to set time for current song: Negative seconds."
            )
            return
        }
        guard Double(seconds) <= nowPlayingDuration else {
            await logger?.debug(
                "Unable to set time for current song: seconds greater than song duration."
            )
            return
        }
        player.playbackTime = Double(seconds)
        await logger?.trace("Set time for current song: \(player.playbackTime)")
    }

}

public protocol AnyPlayableMusicItemCollection {}
extension MusicItemCollection: AnyPlayableMusicItemCollection
where Element: PlayableMusicItem {}
