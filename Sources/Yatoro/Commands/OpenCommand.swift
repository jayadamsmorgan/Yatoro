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
    private static func unknownIndexError(_ index: String) async {
        await executionError("Error: Unknown index \(index)")
    }

    @MainActor
    static func execute(arguments: Array<String>) async {
        do {
            let command = try OpenCommand.parse(arguments)
            logger?.debug("New open command request: \(command)")
            guard let lastResult = SearchManager.shared.lastSearchResult else {
                await executionError("Error: No last search result")
                return
            }
            let index = command.item.lowercased()
            var musicItem: (any MusicItem)? = nil
            if index == "np" || index == "nowplaying" || index == "now" {
                musicItem = Player.shared.nowPlaying
            } else {
                switch lastResult.result {
                case .searchResult(let searchResult):
                    guard let intIndex = Int(index) else {
                        await unknownIndexError(index)
                        return
                    }
                    musicItem = searchResult.result.item(at: intIndex) as? MusicItem

                case .songDescription(let songDescription):
                    if songDescription.artists?.count == 1 && index.starts(with: "w") {
                        musicItem = songDescription.artists?.first
                        break
                    }
                    if index.starts(with: "a") {
                        musicItem = songDescription.album
                        break
                    }
                    guard index.count > 1 else {
                        await unknownIndexError(index)
                        return
                    }
                    guard let intIndex = Int(index.dropFirst()) else {
                        await unknownIndexError(index)
                        return
                    }
                    switch index.first {
                    case "w":
                        musicItem = songDescription.artists?.item(at: intIndex)
                    default:
                        await unknownIndexError(index)
                        return
                    }

                case .albumDescription(let albumDescription):
                    if albumDescription.artists?.count == 1 && index.starts(with: "w") {
                        musicItem = albumDescription.artists?.first
                        break
                    }
                    guard index.count > 1 else {
                        await unknownIndexError(index)
                        return
                    }
                    guard let intIndex = Int(index.dropFirst()) else {
                        await unknownIndexError(index)
                        return
                    }
                    switch index.first {
                    case "s":
                        musicItem = albumDescription.songs.item(at: intIndex)
                    case "w":
                        musicItem = albumDescription.artists?.item(at: intIndex)
                    default:
                        await unknownIndexError(index)
                        return
                    }

                case .artistDescription(let artistDescription):
                    guard index.count > 1 else {
                        await unknownIndexError(index)
                        return
                    }
                    guard let intIndex = Int(index.dropFirst()) else {
                        await unknownIndexError(index)
                        return
                    }
                    switch index.first {
                    case "s":
                        musicItem = artistDescription.topSongs?.item(at: intIndex)
                    case "a":
                        musicItem = artistDescription.lastAlbums?.item(at: intIndex)
                    default:
                        await unknownIndexError(index)
                        return
                    }

                case .playlistDescription(let playlistDescription):
                    guard let intIndex = Int(index) else {
                        await unknownIndexError(index)
                        return
                    }
                    musicItem = playlistDescription.songs.item(at: intIndex)

                case .recommendationDescription(let recommendationDescription):
                    guard index.count > 1 else {
                        await unknownIndexError(index)
                        return
                    }
                    guard let intIndex = Int(index.dropFirst()) else {
                        await unknownIndexError(index)
                        return
                    }
                    switch index.first {
                    case "a":
                        musicItem = recommendationDescription.albums?.item(at: intIndex)
                    case "s":
                        musicItem = recommendationDescription.stations?.item(at: intIndex)
                    case "p":
                        musicItem = recommendationDescription.playlists?.item(at: intIndex)
                    default:
                        await unknownIndexError(index)
                        return
                    }
                }

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
                logger?.error("OpenCommand: Unknown type of the musicItem")
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
