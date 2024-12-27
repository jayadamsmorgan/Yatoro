import ArgumentParser
import MusicKit

typealias InsertionPosition = ApplicationMusicPlayer.Queue.EntryInsertionPosition

struct AddToQueueCommand: AsyncParsableCommand {

    @Argument
    var item: SearchItemIndex?

    @Argument
    var to: InsertionPosition = .tail

    @MainActor
    static func execute(arguments: [String]) async {

        let command: AddToQueueCommand

        do {
            command = try AddToQueueCommand.parse(arguments)
        } catch {
            if let error = error as? CommandError {
                switch error.parserError {
                case .userValidationError(let validationError):
                    let validationError = validationError as! ValidationError
                    await executionError(validationError.message)
                default:
                    await executionError("Error parsing addToQueue command, check arguments")
                }
            }
            return
        }

        logger?.debug("New add to queue command request: \(command)")
        guard
            let lastResult = SearchManager.shared.lastSearchResult
        else {
            await executionError("Error: No current search result")
            return
        }

        switch lastResult.result {

        case .searchResult(let searchResult):

            await addFromSearchResult(searchResult, item: command.item, to: command.to)

        case .songDescription(let songDescription):

            await addFromSongDescription(
                songDescription,
                searchItem: command.item,
                to: command.to
            )

        case .albumDescription(let albumDescription):

            await addFromAlbumDescription(
                albumDescription,
                searchItem: command.item,
                to: command.to
            )

        case .artistDescription(let artistDescription):

            await addFromArtistDescription(
                artistDescription,
                searchItem: command.item,
                to: command.to
            )

        case .playlistDescription(let playlistDescription):

            await addFromPlaylistDescription(
                playlistDescription,
                searchItem: command.item,
                to: command.to
            )

        case .recommendationDescription(let recommendationDescription):

            await addFromRecommendationDescription(
                recommendationDescription,
                searchItem: command.item,
                to: command.to
            )

        }
    }

    @MainActor
    private static func addFromSearchResult(
        _ searchResult: SearchResult,
        item: SearchItemIndex?,
        to: InsertionPosition
    ) async {

        guard searchResult.itemType != .artist else {
            await executionError("Error: Can't add artist to queue")
            return
        }
        let result = searchResult.result

        let item = item ?? .all

        switch result {

        case let result as MusicItemCollection<Song>:
            await addSimple(result, searchItem: item, to: to)

        case let result as MusicItemCollection<Album>:
            await addSimple(result, searchItem: item, to: to)

        case let result as MusicItemCollection<Station>:
            await addSimple(result, searchItem: item, to: to)

        case let result as MusicItemCollection<RecentlyPlayedMusicItem>:
            await addRecentlyPlayedItems(result, searchItem: item, to: to)

        case let result as MusicItemCollection<Playlist>:
            await addPlaylists(result, to: to)

        default: break
        }
    }

    @MainActor
    private static func executionError(_ msg: String) async {
        logger?.debug("CommandParser: addToQueue: \(msg)")
        await CommandInput.shared.setLastCommandOutput(msg)
    }

    @MainActor
    private static func unknownIndexError(_ index: SearchItemIndex.Index) async {
        await executionError("Error: Unknown index \(index)")
    }

    @MainActor
    private static func addSimple<T>(
        _ items: MusicItemCollection<T>,
        searchItem: SearchItemIndex,
        to: InsertionPosition
    ) async where T: PlayableMusicItem {
        switch searchItem {
        case .all:
            await Player.shared.addItemsToQueue(items: items, at: to)
        case .some(let indices):
            let numbers = indices.filter({ $0.number != nil }).map({ $0.number! })
            await Player.shared.addItemsToQueue(
                items: items.selectableCollection(with: numbers),
                at: to
            )
        case .one(let index):
            await addFromCollectionWithIndex(items, index: index, to: to, verbose: true)
        }
    }

    @MainActor
    private static func songsFromPlaylist(_ playlist: Playlist) async
        -> MusicItemCollection<Song>?
    {
        var playlist = playlist
        do {
            if playlist.tracks == nil {
                playlist = try await playlist.with([.tracks])
            }
        } catch {
            logger?.error("Error: addToQueue: songsFromPlaylist: unable to get playlist tracks.")
        }
        guard let tracks = playlist.tracks, !tracks.isEmpty else {
            return nil
        }
        var songs: [Song] = []
        for track in tracks {
            switch track {
            case .song(let song):
                songs.append(song)
            case .musicVideo(_):
                // MusicVideos are not supported yet, skipping them
                continue
            @unknown default:
                // Shouldn't happen
                continue
            }
        }
        if songs.isEmpty {
            return nil
        }
        return .init(songs)
    }

    @MainActor
    private static func addRecentlyPlayedItems(
        _ items: MusicItemCollection<RecentlyPlayedMusicItem>,
        searchItem: SearchItemIndex,
        to: InsertionPosition
    ) async {
        let addRecentlyPlayedOrPlaylist:
            (RecentlyPlayedMusicItem)
                async -> Void = { item in
                    switch item {
                    case .playlist(let playlist):
                        guard let songs = await songsFromPlaylist(playlist) else {
                            return
                        }
                        await Player.shared.addItemsToQueue(items: songs, at: to)
                    default: await Player.shared.addItemsToQueue(items: [item], at: to)
                    }
                }
        switch searchItem {
        case .all:
            var recentlyPlayedItems = Array(items)
            if to == .afterCurrentEntry {
                recentlyPlayedItems = items.reversed()
            }
            for item in recentlyPlayedItems {
                await addRecentlyPlayedOrPlaylist(item)
            }
        case .one(let index):
            guard let number = index.number else {
                return
            }
            guard let item = items.item(at: number) else {
                return
            }
            await addRecentlyPlayedOrPlaylist(item)
        case .some(let indices):

            var recentlyPlayedItems = Array(
                items.selectableCollection(
                    with:
                        indices
                        .filter({ $0.number != nil })
                        .map({ $0.number! })
                )
            )
            if to == .afterCurrentEntry {
                recentlyPlayedItems = items.reversed()
            }
            for item in recentlyPlayedItems {
                await addRecentlyPlayedOrPlaylist(item)
            }
        }
    }

    @MainActor
    private static func addPlaylists(
        _ items: MusicItemCollection<Playlist>,
        to: InsertionPosition
    ) async {
        let playlists: [Playlist]
        if to == .afterCurrentEntry {
            playlists = items.reversed()
        } else {
            playlists = Array(items)
        }
        for playlist in playlists {
            guard let songs = await songsFromPlaylist(playlist) else {
                continue
            }
            await Player.shared.addItemsToQueue(items: songs, at: to)
        }
    }

    @MainActor
    private static func addFromSongDescription(
        _ songDescription: SongDescriptionResult,
        searchItem: SearchItemIndex?,
        to: InsertionPosition
    ) async {
        let searchItem = searchItem ?? .all
        switch searchItem {
        case .all: await Player.shared.addItemsToQueue(items: [songDescription.song], at: to)
        case .some(let indices):
            for index in indices {
                switch index.letter {
                case "a":
                    if let album = songDescription.album {
                        await Player.shared.addItemsToQueue(items: [album], at: to)
                    }
                case "s": await Player.shared.addItemsToQueue(items: [songDescription.song], at: to)
                default: return
                }
            }
        case .one(let index):
            switch index.letter {
            case "a":
                guard let album = songDescription.album else {
                    await unknownIndexError(index)
                    return
                }
                await Player.shared.addItemsToQueue(items: [album], at: to)
            case "s":
                await Player.shared.addItemsToQueue(items: [songDescription.song], at: to)
            case "w":
                await executionError("Cannot add artist to queue")
            default: await unknownIndexError(index)
            }
        }
    }

    @MainActor
    private static func addFromAlbumDescription(
        _ albumDescription: AlbumDescriptionResult,
        searchItem: SearchItemIndex?,
        to: InsertionPosition
    ) async {
        let item = searchItem ?? .all
        switch item {
        case .all:
            await Player.shared.addItemsToQueue(items: albumDescription.songs, at: to)
        case .some(let indices):
            let numbers =
                indices
                .filter({ $0.letter == nil || $0.letter == "s" })
                .filter({ $0.number != nil })
                .map({ $0.number! })
            let collection = albumDescription.songs.selectableCollection(with: numbers)
            guard collection.count != 0 else {
                return
            }
            await Player.shared.addItemsToQueue(items: collection, at: to)
        case .one(let index):
            guard index.letter == "s" || index.letter == nil else {
                await unknownIndexError(index)
                return
            }
            await addFromCollectionWithIndex(albumDescription.songs, index: index, to: to, verbose: true)
        }
    }

    @MainActor
    private static func addFromArtistDescription(
        _ artistDescription: ArtistDescriptionResult,
        searchItem: SearchItemIndex?,
        to: InsertionPosition
    ) async {
        let searchItem = searchItem ?? .all
        switch searchItem {
        case .all:
            if let topSongs = artistDescription.topSongs {
                await Player.shared.addItemsToQueue(items: topSongs, at: to)
            }
            if let albums = artistDescription.lastAlbums {
                await Player.shared.addItemsToQueue(items: albums, at: to)
            }
        case .some(var indices):
            if to == .afterCurrentEntry {
                indices.reverse()
            }
            for index in indices {
                switch index.letter {
                case "s":
                    await addFromCollectionWithIndex(
                        artistDescription.topSongs,
                        index: index,
                        to: to
                    )
                case "a":
                    await addFromCollectionWithIndex(
                        artistDescription.lastAlbums,
                        index: index,
                        to: to
                    )
                default: continue
                }
            }
        case .one(let index):
            switch index.letter {
            case "s":
                await addFromCollectionWithIndex(
                    artistDescription.topSongs,
                    index: index,
                    to: to,
                    verbose: true
                )
            case "a":
                await addFromCollectionWithIndex(
                    artistDescription.lastAlbums,
                    index: index,
                    to: to,
                    verbose: true
                )
            default:
                await unknownIndexError(index)
            }
        }
    }

    @MainActor
    private static func addFromPlaylistDescription(
        _ playlistDescription: PlaylistDescriptionResult,
        searchItem: SearchItemIndex?,
        to: InsertionPosition
    ) async {
        let item = searchItem ?? .all
        switch item {
        case .all:
            await Player.shared.addItemsToQueue(items: playlistDescription.songs, at: to)
        case .some(let indices):
            let numbers =
                indices
                .filter({ $0.letter == "s" || $0.letter == nil })
                .filter({ $0.number != nil })
                .map({ $0.number! })
            await Player.shared.addItemsToQueue(
                items: playlistDescription.songs.selectableCollection(with: numbers),
                at: to
            )
        case .one(let index):
            guard index.letter == nil || index.letter == "s" else {
                await unknownIndexError(index)
                return
            }
            await addFromCollectionWithIndex(playlistDescription.songs, index: index, to: to, verbose: true)
        }
    }

    @MainActor
    private static func addFromCollectionWithIndex<T>(
        _ collection: MusicItemCollection<T>?,
        index: SearchItemIndex.Index,
        to: InsertionPosition,
        verbose: Bool = false
    ) async
    where T: PlayableMusicItem {
        guard let collection else {
            await unknownIndexError(index)
            return
        }
        guard let number = index.number else {
            await unknownIndexError(index)
            return
        }
        guard let item = collection.item(at: number) else {
            await unknownIndexError(index)
            return
        }
        await Player.shared.addItemsToQueue(items: [item], at: to)
    }

    @MainActor
    private static func addFromRecommendationDescription(
        _ recommendationDescription: RecommendationDescriptionResult,
        searchItem: SearchItemIndex?,
        to: InsertionPosition
    ) async {
        let item = searchItem ?? .all
        switch item {
        case .one(let index):
            switch index.letter {
            case "a":
                await addFromCollectionWithIndex(
                    recommendationDescription.albums,
                    index: index,
                    to: to,
                    verbose: true
                )
            case "s":
                await addFromCollectionWithIndex(
                    recommendationDescription.stations,
                    index: index,
                    to: to,
                    verbose: true
                )
            case "p":
                await addFromCollectionWithIndex(
                    recommendationDescription.playlists,
                    index: index,
                    to: to,
                    verbose: true
                )
            default: await unknownIndexError(index)
            }

        case .all:
            // Don't know why you would do that but ok...
            if let playlists = recommendationDescription.playlists {
                await addPlaylists(playlists, to: to)
            }
            if let stations = recommendationDescription.stations {
                await Player.shared.addItemsToQueue(items: stations, at: to)
            }
            if let albums = recommendationDescription.albums {
                await Player.shared.addItemsToQueue(items: albums, at: to)
            }
        case .some(var indices):
            if to == .afterCurrentEntry {
                indices.reverse()
            }
            for index in indices {
                switch index.letter {
                case "a":
                    await addFromCollectionWithIndex(
                        recommendationDescription.albums,
                        index: index,
                        to: to
                    )
                case "s":
                    await addFromCollectionWithIndex(
                        recommendationDescription.stations,
                        index: index,
                        to: to
                    )
                case "p":
                    await addFromCollectionWithIndex(
                        recommendationDescription.playlists,
                        index: index,
                        to: to
                    )
                default: continue
                }
            }
        }
    }

}
