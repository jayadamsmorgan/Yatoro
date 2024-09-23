import AVFoundation
import Logging
import MediaPlayer
import MusadoraKit

public typealias Player = AudioPlayerManager

public typealias LibraryTopResult = MusicLibrarySearchResponse.TopResult
public typealias CatalogTopResult = MusicCatalogSearchResponse.TopResult

public class AudioPlayerManager {

    static let shared = AudioPlayerManager()

    public var logger: Logger?

    public let player = ApplicationMusicPlayer.shared

    public var queue: ApplicationMusicPlayer.Queue.Entries {
        player.queue.entries
    }

    var nowPlaying: (any MusicItem)? {
        player.queue.currentEntry?.item
    }

    var upNext: (any MusicItem)? {
        if let currentEntry = player.queue.currentEntry {
            let index = player.queue.entries.index(
                after: player.queue.entries.firstIndex(of: currentEntry)!
            )
            return player.queue.entries[index].item
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
        logger?.trace("Sending music authorization request...")
        let authorizationStatus = await MusicAuthorization.request()
        guard authorizationStatus == .authorized else {
            logger?.debug(
                "Music authorization not granted. Status: \(authorizationStatus.description)"
            )
            fatalError("Cannot authorize Apple Music request.")
        }
        logger?.debug("Music authorization granted.")
    }

}

// REQUESTS
public extension AudioPlayerManager {

    func getRecentlyPlayed<T>(limit: Int = 10) async
        -> MusicItemCollection<T>?
    where T: Decodable, T: MusicRecentlyPlayedRequestable {
        logger?.trace(
            "Get recently played container for \(T.self): Requesting with limit \(limit)..."
        )
        var request = MusicRecentlyPlayedRequest<T>()
        request.limit = limit
        do {
            let response = try await request.response()
            logger?.debug("Recently played response success: \(response)")
            return response.items
        } catch {
            logger?.error(
                "Failed to make recently played request: \(error.localizedDescription)"
            )
            return nil
        }
    }

    func getRecentlyPlayedContainer(limit: Int = 10) async
        -> MusicItemCollection<RecentlyPlayedMusicItem>?
    {
        logger?.trace(
            "Get recently played container: Requesting with limit \(limit)..."
        )
        var request = MusicRecentlyPlayedContainerRequest()
        request.limit = limit
        do {
            let response = try await request.response()
            logger?.debug(
                "Recently played container response success: \(response)"
            )
            return response.items
        } catch {
            logger?.error(
                "Failed to make recently played container request: \(error.localizedDescription)"
            )
            return nil
        }
    }

    func getUserRecommendedBatch(
        limit: Int = 10
    ) async -> MusicItemCollection<MusicPersonalRecommendation>? {
        logger?.trace(
            "Get user recommended batch: Requesting with limit \(limit)..."
        )
        var request = MusicPersonalRecommendationsRequest()
        request.limit = limit
        do {
            let response = try await request.response()
            logger?.debug("Get user recommended batch: success: \(response)")
            return response.recommendations
        } catch {
            logger?.error(
                "Failed to get user recommended batch: \(error.localizedDescription)"
            )
            return nil
        }
    }

    func getUserLibraryBatch<T>(
        limit: Int = 10,
        onlyOfflineContent: Bool = false
    ) async -> MusicItemCollection<T>?
    where T: MusicLibraryRequestable {
        logger?.trace(
            "Get user library batch for \(T.self): Requesting with limit: \(limit), onlyOfflineContent: \(onlyOfflineContent)..."
        )
        var request = MusicLibraryRequest<T>()
        request.limit = limit
        request.includeOnlyDownloadedContent = onlyOfflineContent
        do {
            let response = try await request.response()
            logger?.debug("Get user library batch: success: \(response)")
            return response.items
        } catch {
            logger?.error(
                "Failed to make user library song request: \(error.localizedDescription)"
            )
            return nil
        }
    }

    func searchCatalogBatch<T>(
        for term: String,
        limit: Int = 10
    ) async -> MusicItemCollection<T>?
    where T: MusicCatalogSearchable {
        logger?.trace(
            "Search catalog batch for \(T.self): Requesting with term \(term), limit \(limit)..."
        )
        var request = MusicCatalogSearchRequest(term: term, types: [T.self])
        if T.self == CatalogTopResult.self {
            logger?.trace(
                "Search catalog batch for \(T.self): Including top results."
            )
            request.includeTopResults = true
        }
        request.limit = limit
        do {
            let response = try await request.response()
            logger?.trace(
                "Search catalog batch for \(T.self): Response success \(response)"
            )
            var collection: MusicItemCollection<T>?
            switch T.self {
            case is Album.Type:
                collection = response.albums as? MusicItemCollection<T>
            case is Song.Type:
                collection = response.songs as? MusicItemCollection<T>
            case is Artist.Type:
                collection = response.artists as? MusicItemCollection<T>
            case is Curator.Type:
                collection = response.curators as? MusicItemCollection<T>
            case is Station.Type:
                collection = response.stations as? MusicItemCollection<T>
            case is Playlist.Type:
                collection = response.playlists as? MusicItemCollection<T>
            case is RadioShow.Type:
                collection = response.radioShows as? MusicItemCollection<T>
            case is CatalogTopResult.Type:
                collection = response.topResults as? MusicItemCollection<T>
            case is RecordLabel.Type:
                collection = response.recordLabels as? MusicItemCollection<T>
            case is MusicVideo.Type:
                collection = response.musicVideos as? MusicItemCollection<T>
            default:
                logger?.error(
                    "Failed to search catalog batch: Type \(T.self) is not supported."
                )
            }
            guard let collection else {
                logger?.error(
                    "Failed to search catalog batch: Unable to transform \(T.self) as \(T.self)"
                )
                return nil
            }
            logger?.debug(
                "Search catalog batch for \(T.self): Success: \(collection)"
            )
            return collection
        } catch {
            logger?.error(
                "Failed to search catalog batch for \(T.self): \(error.localizedDescription)"
            )
            return nil
        }
    }

    func searchUserLibraryBatch<T>(
        for term: String,
        limit: Int = 10
    ) async -> MusicItemCollection<T>?
    where T: MusicLibrarySearchable {
        logger?.trace(
            "Search user library batch for \(T.self): Requesting with term \(term), limit \(limit)..."
        )
        var request = MusicLibrarySearchRequest(term: term, types: [T.self])
        if T.self == LibraryTopResult.self {
            logger?.trace(
                "Search user library batch for \(T.self): Including top results."
            )
            request.includeTopResults = true
        }
        request.limit = limit
        do {
            let response = try await request.response()
            logger?.trace("")
            var collection: MusicItemCollection<T>?
            switch T.self {
            case is Song.Type:
                collection = response.songs as? MusicItemCollection<T>
            case is LibraryTopResult.Type:
                collection = response.topResults as? MusicItemCollection<T>
            case is Playlist.Type:
                collection = response.playlists as? MusicItemCollection<T>
            case is Artist.Type:
                collection = response.artists as? MusicItemCollection<T>
            case is MusicVideo.Type:
                collection = response.musicVideos as? MusicItemCollection<T>
            default:
                logger?.error(
                    "Search user library failed: Unsupported type \(T.self)."
                )
                return nil
            }
            guard let collection else {
                logger?.error(
                    "Search user library failed: Unable to transform \(T.self) type as \(T.self) type."
                )
                return nil
            }
            logger?.debug(
                "Searching user library for \(T.self): success: \(collection)"
            )
            return collection
        } catch {
            logger?.error(
                "Failed to search user library: Request error: \(error.localizedDescription)"
            )
            return nil
        }
    }

    func getAllCatalogCharts(limit: Int = 10) async
        -> MusicCatalogChartsResponse?
    {
        logger?.trace("Get all catalog charts: Requesting...")
        var request = MusicCatalogChartsRequest(types: [
            Song.self, Playlist.self, Album.self, MusicVideo.self,
        ])
        request.limit = limit
        do {
            let response = try await request.response()
            logger?.trace("Get all catalog charts: success: \(response)")
            return response
        } catch {
            logger?.error(
                "Failed to get all catalog charts: \(error.localizedDescription)"
            )
            return nil
        }
    }

    func getSpecificCatalogCharts<T>(
        limit: Int = 10
    ) async -> [MusicCatalogChart<T>]? where T: MusicCatalogChartRequestable {
        logger?.trace("Get catalog charts for type \(T.self): Requesting...")
        var request = MusicCatalogChartsRequest(types: [T.self])
        request.limit = limit
        do {
            let response = try await request.response()
            var result: [MusicCatalogChart<T>]?
            switch T.self {
            case is Song.Type:
                result = response.songCharts as? [MusicCatalogChart<T>]
            case is Playlist.Type:
                result = response.playlistCharts as? [MusicCatalogChart<T>]
            case is Album.Type:
                result = response.albumCharts as? [MusicCatalogChart<T>]
            case is MusicVideo.Type:
                result = response.musicVideoCharts as? [MusicCatalogChart<T>]
            default:
                logger?.error(
                    "Failed to get catalog charts for type \(T.self): Unsupported type."
                )
                return nil
            }
            guard let result else {
                logger?.error(
                    "Failed to get catalog charts: Unable to transform \(T.self) as \(T.self)."
                )
                return nil
            }
            return result
        } catch {
            logger?.error(
                "Failed to get catalog charts for type \(T.self): \(error.localizedDescription)"
            )
            return nil
        }
    }

    func nextMusicItemsBatch<T>(
        for previousBatch: MusicItemCollection<T>,
        limit: Int = 10
    ) async
        -> MusicItemCollection<T>?
    {
        guard previousBatch.hasNextBatch else {
            logger?.trace(
                "Previous batch does not have next batch."
            )
            return nil
        }
        do {
            let response = try await previousBatch.nextBatch(limit: limit)
            guard let response else {
                logger?.debug("Next batch is nil, should not happen.")
                return nil
            }
            logger?.trace("Next batch success: \(response)")
            return response
        } catch {
            logger?.error(
                "Failed to load next batch for previous batch \(previousBatch): \(error.localizedDescription)"
            )
            return nil
        }
    }

    func getUserLibrarySectioned<T, V>(
        for term: String? = nil,
        limit: Int = 10,
        onlyOfflineContent: Bool = false
    ) async
        -> MusicLibrarySectionedResponse<T, V>?
    where T: MusicLibrarySectionRequestable, V: MusicLibraryRequestable {
        logger?.trace(
            "Get user library sectioned for section \(T.self) items \(V.self):"
                + " Requesting with term \(term ?? "'nil'"), limit \(limit), onlyOfflineContent: \(onlyOfflineContent)"
        )
        var request = MusicLibrarySectionedRequest<T, V>()
        request.limit = limit
        if let term {
            request.filterItems(text: term)
        }
        request.includeOnlyDownloadedContent = onlyOfflineContent
        // Items here could also be filtered by more complicated filters and sorted, probably not needed for now
        do {
            let response = try await request.response()
            logger?.debug(
                "Get user library sectioned for section \(T.self) items \(V.self): success: \(response)"
            )
            return response
        } catch {
            logger?.error(
                "Get user library sectioned for section \(T.self) items \(V.self): \(error.localizedDescription)"
            )
            return nil
        }
    }

    // TODO: Search suggestions requests
    // Though I am not sure it is needed
    // As I don't know how to make use of it in UI yet

}

// PLAYBACK
public extension AudioPlayerManager {

    private func _play() async throws {
        logger?.trace("Trying to play...")
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
            logger?.error(
                "Error playing: \(error.localizedDescription) \(type(of: error))"
            )
        }
    }

    func pause() {
        logger?.trace("Trying to pause...")
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
            logger?.error(
                "Failed to play previous: \(error.localizedDescription)"
            )
        }
    }

    func clearQueue() async {
        player.queue.entries = []
    }

    func playLater<T>(_ item: T) async where T: PlayableMusicItem {
        await addItemsToQueue(items: [item], at: .tail)
    }

    func playLater<T>(_ items: MusicItemCollection<T>) async
    where T: PlayableMusicItem {
        await addItemsToQueue(items: items, at: .tail)
    }

    func playNext<T>(_ item: T) async where T: PlayableMusicItem {
        await addItemsToQueue(items: [item], at: .afterCurrentEntry)
    }

    func playNext<T>(_ items: MusicItemCollection<T>) async
    where T: PlayableMusicItem {
        await addItemsToQueue(items: items, at: .afterCurrentEntry)
    }

    private func addItemsToQueue<T>(
        items: MusicItemCollection<T>,
        at position: ApplicationMusicPlayer.Queue.EntryInsertionPosition
    ) async where T: PlayableMusicItem {
        do {
            if player.queue.entries.isEmpty {
                player.queue = .init(for: items)
            } else {
                try await player.queue.insert(items, position: position)
            }
        } catch {
            logger?.error(
                "Unable to add songs to player queue: \(error.localizedDescription)"
            )
            return
        }
        do {
            if !player.isPreparedToPlay {
                logger?.trace("Preparing player...")
                try await player.prepareToPlay()
            }
        } catch {
            logger?.critical("Unable to prepare player: \(error)")
        }
    }

}
