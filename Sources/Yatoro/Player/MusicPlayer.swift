import AVFoundation
import Logging
import MediaPlayer
import MusadoraKit

public typealias Player = AudioPlayerManager

public class AudioPlayerManager {

    static let shared = AudioPlayerManager()

    public var logger: Logger?

    public let player = ApplicationMusicPlayer.shared
    private var queue: [Song] = []

    var nowPlaying: Song? {
        queue.first(where: { $0.id == player.queue.currentEntry?.item?.id })
    }

    var upNext: Song? {
        guard let nowPlaying = nowPlaying else {
            return nil
        }
        guard let nowPlayingIndex = queue.firstIndex(of: nowPlaying) else {
            return nil
        }
        guard nowPlayingIndex < queue.count - 1 else {
            return nil
        }
        return queue[nowPlayingIndex + 1]
    }

    public var status: ApplicationMusicPlayer.PlaybackStatus {
        player.state.playbackStatus
    }
}

// STARTUP
public extension AudioPlayerManager {

    func authorize() async {
        let authorizationStatus = await MusicAuthorization.request()
        guard authorizationStatus == .authorized else {
            logger?.debug("Music authorization not granted. Status: \(authorizationStatus.description)")
            fatalError("Cannot authorize Apple Music request.")
        }
        logger?.debug("Music authorization granted.")
    }

    func loadPreviouslyPlayedQueue() async {
        let previousEntries = player.queue.entries
        guard !previousEntries.isEmpty else {
            return
        }
        for entry in previousEntries {
            do {
                let song = try await MCatalog.song(id: MusicItemID(entry.id))
                self.queue.append(song)
            } catch {
                logger?.error("Failed to find a song with id \(entry.id) from a previous queue.")
            }
        }
    }
}

// SEARCHING
public extension AudioPlayerManager {

    func defaultSearch(for string: String) async -> MusicCatalogSearchResponse? {
        do {
            logger?.trace("Performing default music search for \"\(string)\"...")
            let result = try await MCatalog.search(
                for: string,
                types: [.songs, .artists, .albums, .stations, .playlists]
            )
            logger?.debug("Default search result: \(result). Top results found: \(result.topResults.count)")
            return result
        } catch {
            if let error = error as? MusicDataRequest.Error {
                logger?.error("Failed to perform default search: \(error.detailText)")
            } else {
                logger?.error("Failed to perform default search: \(error.localizedDescription)")
            }
        }
        return nil
    }

    func searchSongs(by string: String) async -> [Song]? {
        do {
            logger?.trace("Performing song search for \"\(string)\"...")
            return try await Array(MCatalog.searchSongs(for: string))
        } catch {
            logger?.error("Failed to perform default search: \(error.localizedDescription)")
        }
        return nil
    }
}

// PLAYBACK
public extension AudioPlayerManager {

    private func checkQueueLengths() -> Bool {
        let queueCount = self.queue.count
        let entriesCount = player.queue.entries.count
        if queueCount != entriesCount {
            logger?.critical(
                "Something went wrong: Queue length mismatch: Queue \(queueCount) != Entries \(entriesCount)"
            )
            return false
        }
        return true
    }

    private func _play() async throws {
        logger?.trace("Trying to play...")
        guard checkQueueLengths() else {
            return
        }
        let playerStatus = player.state.playbackStatus
        logger?.trace("Player status: \(playerStatus)")
        switch player.state.playbackStatus {
        case .paused:
            logger?.trace("Trying to continue playing...")
            try await player.play()
            logger?.trace("Player playing.")
            return
        case .playing:
            logger?.debug("Player is already playing.")
            return
        case .stopped:
            guard !self.queue.isEmpty else {
                logger?.debug("Trying to play empty queue.")
                // TODO: populate with automatic music suggestions
                return
            }
            try await player.play()
        case .interrupted:
            logger?.critical("Something went wrong: Player status interrupted.")
            return
        case .seekingForward, .seekingBackward:
            logger?.trace("Trying to stop seeking...")
            player.endSeeking()
            return
        @unknown default:
            logger?.error("Unknown player status \(playerStatus).")
            return
        }
    }

    func play() async {
        do {
            try await _play()
        } catch {
            logger?.error("Error playing: \(error.localizedDescription) \(type(of: error))")
        }
    }

    func pause() {
        logger?.trace("Trying to pause...")
        guard checkQueueLengths() else {
            return
        }
        let playerStatus = player.state.playbackStatus
        logger?.trace("Player status: \(playerStatus)")
        switch player.state.playbackStatus {
        case .paused:
            logger?.debug("Player is already paused.")
            return
        case .playing:
            player.pause()
            logger?.trace("Player paused.")
            return
        case .stopped:
            logger?.error("Trying to pause stopped player.")
            return
        case .interrupted:
            logger?.critical("Something went wrong: Player status interrupted.")
            return
        case .seekingForward, .seekingBackward:
            logger?.trace("Trying to stop seeking...")
            player.endSeeking()
            player.pause()
            logger?.trace("Player stopped seeking and paused.")
            return
        @unknown default:
            logger?.error("Unknown player status \(playerStatus).")
            return
        }
    }

    func playPauseToggle() async {
        switch player.state.playbackStatus {
        case .paused:
            await self.play()
        case .playing:
            self.pause()
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
            logger?.error("Failed to play next: \(error.localizedDescription)")
        }
    }

    func playPrevious() async {
        do {
            try await player.skipToPreviousEntry()
        } catch {
            logger?.error("Failed to play previous: \(error.localizedDescription)")
        }
    }

    func clearQueue() async {
        player.queue.entries = []
        self.queue = []
    }

    func playLater(_ song: Song) async {
        await addSongsToQueue(songs: [song], at: .tail)
    }

    func playLater(_ songs: [Song]) async {
        await addSongsToQueue(songs: songs, at: .tail)
    }

    func playNext(_ song: Song) async {
        await addSongsToQueue(songs: [song], at: .afterCurrentEntry)
    }

    func playNext(_ songs: [Song]) async {
        await addSongsToQueue(songs: songs, at: .afterCurrentEntry)
    }

    private func addSongsToQueue(
        songs: [Song],
        at position: ApplicationMusicPlayer.Queue.EntryInsertionPosition
    ) async {
        do {
            if self.queue.isEmpty {
                player.queue = .init(for: songs)
            } else {
                try await player.queue.insert(songs, position: position)
            }
        } catch {
            logger?.error("Unable to add songs to player queue: \(error.localizedDescription)")
            return
        }
        if self.queue.isEmpty {
            self.queue = songs
        } else {
            switch position {
            case .afterCurrentEntry:
                self.queue.insert(contentsOf: songs, at: 1)
            case .tail:
                self.queue.append(contentsOf: songs)
            @unknown default:
                logger?.error("Unknown Music Player position: \(position)")
                return
            }
        }
        do {
            if !player.isPreparedToPlay {
                logger?.trace("Preparing player...")
                try await player.prepareToPlay()
            }
        } catch {
            logger?.critical("Unable to prepare player: \(error)")
        }
        _ = checkQueueLengths()
    }

}
