import ArgumentParser
import MusicKit

struct OpenCommand: AsyncParsableCommand {

    @Flag(name: .shortAndLong)
    var inPlace: Bool = false

    @Argument
    var item: String

    @MainActor
    private static func executionError(_ msg: String) async {
        logger?.debug("CommandParser: open: \(msg)")
        await CommandInput.shared.setLastCommandOutput(msg)
    }

    @MainActor
    private static func unknownIndexError(_ index: SearchItemIndex.Index) async {
        await executionError("Error: Unknown index \(index)")
    }

    @MainActor
    private static func musicItemFromCollectionWithIndex(
        collection: (any AnyMusicItemCollection)?,
        index: SearchItemIndex.Index
    ) -> (any MusicItem)? {
        if let number = index.number {
            return collection?.item(at: number) as? MusicItem
        }
        if collection?.count == 1 {
            return collection?.first as? MusicItem
        }
        return nil
    }

    @MainActor
    static func execute(arguments: [String]) async {

        let command: OpenCommand

        do {
            command = try OpenCommand.parse(arguments)
            logger?.debug("New open command request: \(command)")
            guard let lastResult = SearchManager.shared.lastSearchResult else {
                await executionError("Error: No last search result")
                return
            }
            let indexString = command.item.lowercased()
            var musicItem: (any MusicItem)? = nil

            guard indexString != "np" && indexString != "nowplaying" && indexString != "now" else {
                if let nowPlaying = Player.shared.nowPlaying {
                    try await openSong(nowPlaying)
                }
                return
            }

            let index = SearchItemIndex.Index(from: indexString)

            guard index.isValid() else {
                await unknownIndexError(index)
                return
            }

            switch lastResult.result {
            case .searchResult(let searchResult):
                musicItem = musicItemFromCollectionWithIndex(
                    collection: searchResult.result,
                    index: index
                )

            case .songDescription(let songDescription):
                switch index.letter {
                case "w":
                    musicItem = musicItemFromCollectionWithIndex(
                        collection: songDescription.artists,
                        index: index
                    )
                case "a":
                    musicItem = songDescription.album
                default: break
                }

            case .albumDescription(let albumDescription):
                switch index.letter {
                case "w":
                    musicItem = musicItemFromCollectionWithIndex(
                        collection: albumDescription.artists,
                        index: index
                    )
                case "s":
                    musicItem = musicItemFromCollectionWithIndex(
                        collection: albumDescription.songs,
                        index: index
                    )
                default: break
                }

            case .artistDescription(let artistDescription):
                switch index.letter {
                case "s":
                    musicItem = musicItemFromCollectionWithIndex(
                        collection: artistDescription.topSongs,
                        index: index
                    )
                case "a":
                    musicItem = musicItemFromCollectionWithIndex(
                        collection: artistDescription.lastAlbums,
                        index: index
                    )
                case "w":
                    musicItem = artistDescription.artist
                default: break
                }

            case .playlistDescription(let playlistDescription):
                switch index.letter {
                case nil, "s":
                    musicItem = musicItemFromCollectionWithIndex(
                        collection: playlistDescription.songs,
                        index: index
                    )
                default: break
                }

            case .recommendationDescription(let recommendationDescription):
                switch index.letter {
                case "a":
                    musicItem = musicItemFromCollectionWithIndex(
                        collection: recommendationDescription.albums,
                        index: index
                    )
                case "s":
                    musicItem = musicItemFromCollectionWithIndex(
                        collection: recommendationDescription.stations,
                        index: index
                    )
                case "p":
                    musicItem = musicItemFromCollectionWithIndex(
                        collection: recommendationDescription.playlists,
                        index: index
                    )
                default: break
                }

            case .help:
                await CommandInput.shared.setLastCommandOutput("Help page has no items to open.")
                return

            }
            guard let musicItem else {
                await unknownIndexError(index)
                return
            }

            switch musicItem {

            case let songItem as Song:
                try await openSong(songItem)

            case let albumItem as Album:
                try await openAlbum(albumItem)

            case let artistItem as Artist:
                try await openArtist(artistItem)

            case let playlistItem as Playlist:
                try await openPlaylist(playlistItem, inPlace: command.inPlace)

            case _ as Station:
                await executionError("Error: Not yet implemented")

            case let recommendationItem as MusicPersonalRecommendation:
                try await openRecommendation(recommendationItem)

            case let recentlyPlayedItem as RecentlyPlayedMusicItem:
                try await openRecentlyPlayed(recentlyPlayedItem, inPlace: command.inPlace)

            default:
                await executionError("Error: Unknown type of the musicItem")
            }

        } catch {
            if let error = error as? CommandError {
                switch error.parserError {
                case .userValidationError(let validationError):
                    let validationError = validationError as! ValidationError
                    await executionError(validationError.message)
                default:
                    await executionError("Error: wrong arguments")
                }
            }
        }
    }

    @MainActor
    private static func openSong(_ songItem: Song) async throws {
        let songItem = try await songItem.with([.albums, .artists])
        let songDescription = SongDescriptionResult(
            song: songItem,
            artists: songItem.artists,
            album: songItem.albums?.first
        )
        SearchManager.shared.lastSearchResult = .init(
            previous: SearchManager.shared.lastSearchResult,
            .songDescription(songDescription),
            inPlace: false
        )
    }

    @MainActor
    private static func openPlaylist(_ playlistItem: Playlist, inPlace: Bool) async throws {
        let playlistItem = try await playlistItem.with([.tracks])
        var songs: [Song] = []
        if let tracks = playlistItem.tracks {
            for track in tracks {
                switch track {
                case .song(let song):
                    songs.append(song)
                case .musicVideo(_): break
                @unknown default: break
                }
            }
        }
        let playlistDescription = PlaylistDescriptionResult(
            playlist: playlistItem,
            songs: MusicItemCollection(songs)
        )
        SearchManager.shared.lastSearchResult = .init(
            previous: SearchManager.shared.lastSearchResult,
            .playlistDescription(playlistDescription),
            inPlace: inPlace
        )
    }

    @MainActor
    private static func openAlbum(_ albumItem: Album) async throws {
        let albumItem = try await albumItem.with([.tracks, .artists])
        var songs: [Song] = []
        if let tracks = albumItem.tracks {
            for track in tracks {
                switch track {
                case .song(let song): songs.append(song)
                case .musicVideo(_): break
                @unknown default: break
                }
            }
        }
        let albumDescription = AlbumDescriptionResult(
            album: albumItem,
            songs: MusicItemCollection(songs),
            artists: albumItem.artists
        )
        SearchManager.shared.lastSearchResult = .init(
            previous: SearchManager.shared.lastSearchResult,
            .albumDescription(albumDescription),
            inPlace: false
        )
    }

    @MainActor
    private static func openArtist(_ artistItem: Artist) async throws {
        let artistItem = try await artistItem.with([.topSongs, .albums])
        let artistDescription = ArtistDescriptionResult(
            artist: artistItem,
            topSongs: artistItem.topSongs,
            lastAlbums: artistItem.albums
        )
        SearchManager.shared.lastSearchResult = .init(
            previous: SearchManager.shared.lastSearchResult,
            .artistDescription(artistDescription),
            inPlace: false
        )
    }

    @MainActor
    private static func openRecommendation(_ recommendationItem: MusicPersonalRecommendation) async throws {
        var playlists: MusicItemCollection<Playlist>?
        var stations: MusicItemCollection<Station>?
        var albums: MusicItemCollection<Album>?
        // Sometimes the recommendationItem is received with 'tracks' property,
        // Sometimes it's received containing playlists, stations and albums as a separate properties...
        // That's how Apple Music API works... :(
        if recommendationItem.items.isEmpty {
            for type in recommendationItem.types {
                switch type {
                case is Playlist.Type:
                    // TODO: Probably check if playlists are empty anyway, maybe that happens, same for other types
                    playlists = recommendationItem.playlists
                case is Album.Type:
                    albums = recommendationItem.albums
                case is Station.Type:
                    stations = recommendationItem.stations
                default: break
                }
            }
        } else {
            var playlistsArr: [Playlist] = []
            var stationsArr: [Station] = []
            var albumsArr: [Album] = []
            for item in recommendationItem.items {
                switch item {
                case .album(let album):
                    albumsArr.append(album)
                case .station(let station):
                    stationsArr.append(station)
                case .playlist(let playlist):
                    playlistsArr.append(playlist)
                @unknown default: break
                }
            }
            if !playlistsArr.isEmpty {
                playlists = MusicItemCollection(playlistsArr)
            }
            if !stationsArr.isEmpty {
                stations = MusicItemCollection(stationsArr)
            }
            if !albumsArr.isEmpty {
                albums = MusicItemCollection(albumsArr)
            }
        }
        let recommendationDescription = RecommendationDescriptionResult(
            recommendation: recommendationItem,
            albums: albums,
            stations: stations,
            playlists: playlists
        )
        SearchManager.shared.lastSearchResult = .init(
            previous: SearchManager.shared.lastSearchResult,
            .recommendationDescription(recommendationDescription),
            inPlace: false
        )
    }

    @MainActor
    private static func openRecentlyPlayed(_ recentlyPlayedItem: RecentlyPlayedMusicItem, inPlace: Bool) async throws {
        switch recentlyPlayedItem {
        case .album(let albumItem):
            try await openAlbum(albumItem)
        case .station(_):
            await executionError("Error: Not yet implemented")
        case .playlist(let playlistItem):
            try await openPlaylist(playlistItem, inPlace: inPlace)
        @unknown default:
            logger?.error("OpenCommand: Unknown type of recentlyPlayedItem")
        }
    }

}
