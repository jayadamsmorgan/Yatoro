import ArgumentParser
import MusicKit

struct AddToQueueCommand: AsyncParsableCommand {

    @Argument
    var item: SearchItemIndex?

    @Argument
    var to: ApplicationMusicPlayer.Queue.EntryInsertionPosition = .tail

    @MainActor
    private static func executionError(_ msg: String) async {
        logger?.debug("CommandParser: addToQueue: \(msg)")
        await CommandInput.shared.setLastCommandOutput(msg)
    }

    @MainActor
    private static func unknownIndexError(_ index: String) async {
        await executionError("Error: Uknown index \(index)")
    }

    @MainActor
    private static func songsFromPlaylist(_ playlist: Playlist) async throws
        -> [Song]?
    {
        let item = try await playlist.with([.tracks])
        guard let tracks = item.tracks, !tracks.isEmpty else {
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
        return songs
    }

    @MainActor
    static func execute(arguments: Array<String>) async {
        do {
            let command = try AddToQueueCommand.parse(arguments)
            logger?.debug("New add to queue command request: \(command)")
            guard
                let lastResult = SearchManager.shared.lastSearchResult
            else {
                await executionError("Error: No current search result")
                return
            }

            switch lastResult.result {
            case .searchResult(let searchResult):
                guard searchResult.itemType != .artist else {
                    await executionError("Error: Can't add artist to queue")
                    return
                }
                let result = searchResult.result

                let item = command.item ?? .all

                switch item {

                case .all:
                    switch result {

                    case let result as MusicItemCollection<Song>:
                        await Player.shared.addItemsToQueue(items: result, at: command.to)

                    case let result as MusicItemCollection<Album>:
                        await Player.shared.addItemsToQueue(items: result, at: command.to)

                    case let result as MusicItemCollection<RecentlyPlayedMusicItem>:
                        let recentlyPlayedItems: [RecentlyPlayedMusicItem]
                        if command.to == .afterCurrentEntry {
                            recentlyPlayedItems = result.reversed()
                        } else {
                            recentlyPlayedItems = Array(result)
                        }
                        for recentlyPlayedItem in recentlyPlayedItems {
                            switch recentlyPlayedItem {
                            case .playlist(let playlist):
                                guard let songs = try await songsFromPlaylist(playlist) else {
                                    continue
                                }
                                await Player.shared.addItemsToQueue(items: .init(songs), at: command.to)
                            default: await Player.shared.addItemsToQueue(items: [recentlyPlayedItem], at: command.to)
                            }
                        }
                        await Player.shared.addItemsToQueue(items: result, at: command.to)

                    case let result as MusicItemCollection<Playlist>:
                        let playlists: [Playlist]
                        if command.to == .afterCurrentEntry {
                            playlists = result.reversed()
                        } else {
                            playlists = Array(result)
                        }
                        for playlist in playlists {
                            guard let songs = try await songsFromPlaylist(playlist) else {
                                continue
                            }
                            await Player.shared.addItemsToQueue(items: .init(songs), at: command.to)
                        }

                    case let result as MusicItemCollection<Station>:
                        await Player.shared.addItemsToQueue(items: result, at: command.to)

                    default: break
                    }

                case .some(let indices):
                    switch result {

                    case let result as MusicItemCollection<Song>:
                        var songs: [Song] = []
                        for index in indices {
                            guard let index = Int(index) else {
                                continue
                            }
                            if let item = result.item(at: index) {
                                songs.append(item)
                            }
                        }
                        await Player.shared.addItemsToQueue(items: .init(songs), at: command.to)

                    case let result as MusicItemCollection<Album>:
                        var albums: [Album] = []
                        for index in indices {
                            guard let index = Int(index) else {
                                continue
                            }
                            if let item = result.item(at: index) {
                                albums.append(item)
                            }
                        }
                        await Player.shared.addItemsToQueue(items: .init(albums), at: command.to)

                    case let result as MusicItemCollection<RecentlyPlayedMusicItem>:
                        var items: [RecentlyPlayedMusicItem] = []
                        for index in indices {
                            guard let index = Int(index) else {
                                continue
                            }
                            if let item = result.item(at: index) {
                                items.append(item)
                            }
                        }
                        if command.to == .afterCurrentEntry {
                            items.reverse()
                        }
                        for item in items {
                            switch item {
                            case .playlist(let playlist):
                                guard let songs = try await songsFromPlaylist(playlist) else {
                                    continue
                                }
                                await Player.shared.addItemsToQueue(items: .init(songs), at: command.to)
                            default:
                                await Player.shared.addItemsToQueue(items: [item], at: command.to)
                            }
                        }

                    case let result as MusicItemCollection<Playlist>:
                        var items: [Playlist] = []
                        for index in indices {
                            guard let index = Int(index) else {
                                continue
                            }
                            if let item = result.item(at: index) {
                                items.append(item)
                            }
                        }
                        if command.to == .afterCurrentEntry {
                            items.reverse()
                        }
                        for playlist in items {
                            if let songs = try await songsFromPlaylist(playlist) {
                                await Player.shared.addItemsToQueue(items: .init(songs), at: command.to)
                            }
                        }

                    case let result as MusicItemCollection<Station>:
                        var items: [Station] = []
                        for index in indices {
                            guard let index = Int(index) else {
                                continue
                            }
                            if let item = result.item(at: index) {
                                items.append(item)
                            }
                        }
                        await Player.shared.addItemsToQueue(items: .init(items), at: command.to)

                    default: break

                    }

                case .one(let index):
                    guard let int = Int(index) else {
                        return
                    }
                    guard let item = result.item(at: int) else {
                        return
                    }
                    switch item {
                    case let item as Song:
                        await Player.shared.addItemsToQueue(items: [item], at: command.to)
                    case let item as Album:
                        await Player.shared.addItemsToQueue(items: [item], at: command.to)
                    case let item as RecentlyPlayedMusicItem:
                        switch item {
                        case .playlist(let playlist):
                            guard let songs = try await songsFromPlaylist(playlist) else {
                                await executionError("Error: No songs in playlist, nothing to add.")
                                return
                            }
                            await Player.shared.addItemsToQueue(items: .init(songs), at: command.to)
                        default:
                            await Player.shared.addItemsToQueue(items: [item], at: command.to)
                        }
                    case let item as Playlist:
                        guard let songs = try await songsFromPlaylist(item) else {
                            await executionError("Error: No songs in playlist, nothing to add.")
                            return
                        }
                        await Player.shared.addItemsToQueue(items: .init(songs), at: command.to)
                    case let item as Station:
                        await Player.shared.addItemsToQueue(items: [item], at: command.to)
                    default: break
                    }
                }
            case .songDescription(let songDescription):
                guard let item = command.item else {
                    // Add itself
                    await Player.shared.addItemsToQueue(items: [songDescription.song], at: command.to)
                    return
                }
                await executionError("Error: Cannot add to queue item \(item)")
            case .albumDescription(let albumDescription):
                guard let item = command.item else {
                    // Add songs
                    await Player.shared.addItemsToQueue(items: albumDescription.songs, at: command.to)
                    return
                }
                switch item {
                case .all:
                    await Player.shared.addItemsToQueue(items: albumDescription.songs, at: command.to)
                case .some(let indices):
                    await executionError("Error: Cannot add multiple items from description to queue")
                    for index in indices {
                        if index.starts(with: "s") && index.count > 1 {  // Songs
                            guard let intIndex = Int(index.dropFirst(1)) else {
                                await unknownIndexError(index)
                                return
                            }
                            guard let item = albumDescription.songs.item(at: intIndex) else {
                                await executionError("Error: Unknown index \(index)")
                                return
                            }
                            await Player.shared.addItemsToQueue(items: [item], at: command.to)
                        }
                    }
                case .one(let index):
                    let index = index.lowercased()
                    if index.starts(with: "w") {  // Artists
                        await executionError("Error: Cannot add artist to queue")
                    } else if index.starts(with: "s") && index.count > 1 {  // Songs
                        guard let intIndex = Int(index.dropFirst(1)) else {
                            await unknownIndexError(index)
                            return
                        }
                        guard let item = albumDescription.songs.item(at: intIndex) else {
                            await unknownIndexError(index)
                            return
                        }
                        await Player.shared.addItemsToQueue(items: [item], at: command.to)
                    } else {
                        await unknownIndexError(index)
                    }

                }

            case .artistDescription(let artistDescription):
                guard let item = command.item else {
                    // Top Songs
                    guard let topSongs = artistDescription.topSongs else {
                        await executionError("Nothing to add")
                        return
                    }
                    await Player.shared.addItemsToQueue(items: topSongs, at: command.to)
                    return
                }
                switch item {
                case .all:
                    guard artistDescription.topSongs != nil || artistDescription.lastAlbums != nil else {
                        await executionError("Nothing to add")
                        return
                    }
                    if let topSongs = artistDescription.topSongs {
                        await Player.shared.addItemsToQueue(items: topSongs, at: command.to)
                    }
                    if let lastAlbums = artistDescription.lastAlbums {
                        await Player.shared.addItemsToQueue(items: lastAlbums, at: command.to)
                    }
                case .some(let indices):
                    for index in indices {
                        let index = index.lowercased()
                        if index.starts(with: "t") && index.count > 1 {  // Top Songs
                            guard let intIndex = Int(index.dropFirst(1)) else {
                                await unknownIndexError(index)
                                return
                            }
                            guard let item = artistDescription.topSongs?.item(at: intIndex) else {
                                await unknownIndexError(index)
                                return
                            }
                            await Player.shared.addItemsToQueue(items: [item], at: command.to)
                        } else if index.starts(with: "a") && index.count > 1 {  // Last Albums
                            guard let intIndex = Int(index.dropFirst(1)) else {
                                await unknownIndexError(index)
                                return
                            }
                            guard let item = artistDescription.lastAlbums?.item(at: intIndex) else {
                                await unknownIndexError(index)
                                return
                            }
                            await Player.shared.addItemsToQueue(items: [item], at: command.to)
                        } else {
                            await unknownIndexError(index)
                        }
                    }

                case .one(let index):
                    let index = index.lowercased()
                    if index.starts(with: "t") && index.count > 1 {  // Top Songs
                        guard let intIndex = Int(index.dropFirst(1)) else {
                            await unknownIndexError(index)
                            return
                        }
                        guard let item = artistDescription.topSongs?.item(at: intIndex) else {
                            await unknownIndexError(index)
                            return
                        }
                        await Player.shared.addItemsToQueue(items: [item], at: command.to)
                    } else if index.starts(with: "a") && index.count > 1 {  // Last Albums
                        guard let intIndex = Int(index.dropFirst(1)) else {
                            await unknownIndexError(index)
                            return
                        }
                        guard let item = artistDescription.lastAlbums?.item(at: intIndex) else {
                            await unknownIndexError(index)
                            return
                        }
                        await Player.shared.addItemsToQueue(items: [item], at: command.to)
                    } else {
                        await unknownIndexError(index)
                    }
                }

            case .playlistDescription(let playlistDescription):
                guard let item = command.item else {
                    await Player.shared.addItemsToQueue(items: playlistDescription.songs, at: command.to)
                    return
                }
                switch item {
                case .all:
                    await Player.shared.addItemsToQueue(items: playlistDescription.songs, at: command.to)
                case .some(let indices):
                    var items: [Song] = []
                    for index in indices {
                        guard let intIndex = Int(index) else {
                            await unknownIndexError(index)
                            return
                        }
                        guard let item = playlistDescription.songs.item(at: intIndex) else {
                            await unknownIndexError(index)
                            return
                        }
                        items.append(item)
                    }
                    await Player.shared.addItemsToQueue(items: MusicItemCollection(items), at: command.to)

                case .one(let index):
                    guard let intIndex = Int(index) else {
                        await unknownIndexError(index)
                        return
                    }
                    guard let item = playlistDescription.songs.item(at: intIndex) else {
                        await unknownIndexError(index)
                        return
                    }
                    await Player.shared.addItemsToQueue(items: [item], at: command.to)
                }

            case .recommendationDescription(let recommendationDescription):
                guard let item = command.item else {
                    // Not sure what to add here
                    await executionError("Error: Not yet implemented")
                    return
                }
                switch item {
                case .all:
                    // Same
                    await executionError("Error: Not yet implemented")
                    return
                case .some(_):
                    await executionError("Error: Not yet implemented")
                    return

                case .one(let index):
                    let index = index.lowercased()
                    guard index.count > 1 else {
                        await unknownIndexError(index)
                        return
                    }
                    guard let intIndex = Int(index.dropFirst(1)) else {
                        await unknownIndexError(index)
                        return
                    }
                    if index.starts(with: "p") {  // Playlist
                        guard let item = recommendationDescription.playlists?.item(at: intIndex) else {
                            await unknownIndexError(index)
                            return
                        }
                        await Player.shared.addItemsToQueue(items: [item], at: command.to)
                    } else if index.starts(with: "s") {  // Station
                        guard let item = recommendationDescription.stations?.item(at: intIndex) else {
                            await unknownIndexError(index)
                            return
                        }
                        await Player.shared.addItemsToQueue(items: [item], at: command.to)
                    } else if index.starts(with: "a") {  // Album
                        guard let item = recommendationDescription.albums?.item(at: intIndex) else {
                            await unknownIndexError(index)
                            return
                        }
                        await Player.shared.addItemsToQueue(items: [item], at: command.to)
                    } else {
                        await unknownIndexError(index)
                        return
                    }
                }

            }

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
        }
    }
}
