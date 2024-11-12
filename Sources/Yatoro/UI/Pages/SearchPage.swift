import Foundation
import MusicKit
import SwiftNotCurses

@MainActor
public class SearchPage: Page {

    private let plane: Plane
    private let pageNamePlane: Plane
    private let borderPlane: Plane
    private let searchPhrasePlane: Plane
    private let itemIndicesPlane: Plane

    private var state: PageState

    private var lastSearchTime: Date
    private var searchCache: [Page]

    private let colorConfig: Config.UIConfig.Colors.Search

    private var maxItemsDisplayed: Int {
        (Int(self.state.height) - 7) / 5
    }

    public func onResize(newPageState: PageState) async {
        self.state = newPageState
        plane.updateByPageState(state)

        borderPlane.updateByPageState(
            .init(
                absX: 0,
                absY: 0,
                width: state.width,
                height: state.height
            )
        )
        borderPlane.erase()
        borderPlane.windowBorder(width: state.width, height: state.height)

        pageNamePlane.updateByPageState(.init(absX: 2, absY: 0, width: 13, height: 1))

        itemIndicesPlane.erase()
        itemIndicesPlane.updateByPageState(.init(absX: 1, absY: 1, width: 1, height: state.height - 2))

        for case let item as DestroyablePage in searchCache {
            await item.destroy()
        }
        self.searchCache = []
    }

    public func getPageState() async -> PageState { self.state }

    public func getMaxDimensions() async -> (width: UInt32, height: UInt32)? { nil }

    public func getMinDimensions() async -> (width: UInt32, height: UInt32) { (23, 17) }

    public init?(stdPlane: Plane, state: PageState, colorConfig: Config.UIConfig.Colors.Search) {
        self.state = state
        guard
            let plane = Plane(
                in: stdPlane,
                opts: .init(
                    x: 30,
                    y: 0,
                    width: state.width,
                    height: state.height - 3,
                    debugID: "SEARCH_PAGE"
                )
            )
        else {
            return nil
        }
        plane.backgroundColor = colorConfig.page.background
        plane.foregroundColor = colorConfig.page.foreground
        plane.blank()
        self.plane = plane

        guard
            let borderPlane = Plane(
                in: plane,
                state: .init(
                    absX: 0,
                    absY: 0,
                    width: state.width,
                    height: state.height
                ),
                debugID: "SEARCH_BORDER"
            )
        else {
            return nil
        }
        borderPlane.backgroundColor = colorConfig.border.background
        borderPlane.foregroundColor = colorConfig.border.foreground
        borderPlane.windowBorder(width: state.width, height: state.height)
        self.borderPlane = borderPlane

        guard
            let searchPhrasePlane = Plane(
                in: plane,
                state: .init(absX: 2, absY: 0, width: 1, height: 1),
                debugID: "SEARCH_SP"
            )
        else {
            return nil
        }
        searchPhrasePlane.backgroundColor = colorConfig.searchPhrase.background
        searchPhrasePlane.foregroundColor = colorConfig.searchPhrase.foreground
        self.searchPhrasePlane = searchPhrasePlane

        guard
            let pageNamePlane = Plane(
                in: plane,
                state: .init(
                    absX: 2,
                    absY: 0,
                    width: 6,
                    height: 1
                ),
                debugID: "SEARCH_PAGE_NAME"
            )
        else {
            return nil
        }
        pageNamePlane.backgroundColor = colorConfig.pageName.background
        pageNamePlane.foregroundColor = colorConfig.pageName.foreground
        self.pageNamePlane = pageNamePlane

        guard
            let itemIndicesPlane = Plane(
                in: plane,
                state: .init(
                    absX: 1,
                    absY: 1,
                    width: 1,
                    height: state.height - 2
                ),
                debugID: "SEARCH_II"
            )
        else {
            return nil
        }
        itemIndicesPlane.backgroundColor = colorConfig.itemIndices.background
        itemIndicesPlane.foregroundColor = colorConfig.itemIndices.foreground
        self.itemIndicesPlane = itemIndicesPlane

        self.searchCache = []
        self.lastSearchTime = .now
        self.colorConfig = colorConfig
    }

    public func render() async {

        guard let result = SearchManager.shared.lastSearchResult else {
            pageNamePlane.width = 6
            pageNamePlane.putString("Search", at: (0, 0))
            searchPhrasePlane.updateByPageState(.init(absX: 2, absY: 0, width: 1, height: 1))
            searchPhrasePlane.erase()
            itemIndicesPlane.erase()
            return
        }

        switch result.searchType {

        case .recentlyPlayed:

            pageNamePlane.width = 15
            pageNamePlane.putString("Recently Played", at: (0, 0))
            searchPhrasePlane.updateByPageState(.init(absX: 2, absY: 0, width: 1, height: 1))
            searchPhrasePlane.erase()

            await update(result: result)
        case .recommended:
            pageNamePlane.width = 11
            pageNamePlane.putString("Recommended", at: (0, 0))
            searchPhrasePlane.updateByPageState(.init(absX: 2, absY: 0, width: 1, height: 1))
            searchPhrasePlane.erase()

            await update(result: result)

        case .catalogSearch:
            guard let searchPhrase = result.searchPhrase else {
                return
            }
            switch result.itemType {
            case .song:
                pageNamePlane.width = 14
                pageNamePlane.putString("Catalog songs:", at: (0, 0))
            case .album:
                pageNamePlane.width = 15
                pageNamePlane.putString("Catalog albums:", at: (0, 0))
            case .artist:
                pageNamePlane.width = 16
                pageNamePlane.putString("Catalog artists:", at: (0, 0))
            case .playlist:
                pageNamePlane.width = 18
                pageNamePlane.putString("Catalog playlists:", at: (0, 0))
            case .station:
                pageNamePlane.width = 17
                pageNamePlane.putString("Catalog stations:", at: (0, 0))
            }
            let searchPhrasePlaneWidth = min(
                UInt32(searchPhrase.count),
                self.state.width - pageNamePlane.width - 4
            )
            searchPhrasePlane.updateByPageState(
                .init(
                    absX: Int32(pageNamePlane.width) + 3,
                    absY: 0,
                    width: searchPhrasePlaneWidth,
                    height: 1
                )
            )
            searchPhrasePlane.putString(searchPhrase, at: (0, 0))

            await update(result: result)

        case .librarySearch:
            guard let searchPhrase = result.searchPhrase else {
                return
            }
            switch result.itemType {
            case .song:
                pageNamePlane.width = 14
                pageNamePlane.putString("Library songs:", at: (0, 0))
            case .album:
                pageNamePlane.width = 15
                pageNamePlane.putString("Library albums:", at: (0, 0))
            case .artist:
                pageNamePlane.width = 16
                pageNamePlane.putString("Library artists:", at: (0, 0))
            case .playlist:
                pageNamePlane.width = 18
                pageNamePlane.putString("Library playlists:", at: (0, 0))
            case .station:
                pageNamePlane.width = 17
                pageNamePlane.putString("Library stations:", at: (0, 0))
            }
            searchPhrasePlane.updateByPageState(
                .init(
                    absX: Int32(pageNamePlane.width) + 3,
                    absY: 0,
                    width: UInt32(searchPhrase.count),
                    height: 1
                )
            )
            searchPhrasePlane.putString(searchPhrase, at: (0, 0))

            await update(result: result)

        }

    }

    private func update(result: SearchResult) async {
        guard searchCache.isEmpty || lastSearchTime != result.timestamp else {
            return
        }
        logger?.debug("Search UI update.")

        itemIndicesPlane.erase()
        for case let item as DestroyablePage in searchCache {
            await item.destroy()
        }

        searchCache = []
        lastSearchTime = result.timestamp
        let items = result.result
        switch items {
        case let songs as MusicItemCollection<Song>:
            songItems(songs: songs)
        case let albums as MusicItemCollection<Album>:
            albumItems(albums: albums)
        case let artists as MusicItemCollection<Artist>:
            await artistItems(artists: artists)
        case let playlists as MusicItemCollection<Playlist>:
            playlistItems(playlists: playlists)
        case let stations as MusicItemCollection<Station>:
            stationItems(stations: stations)
        case let recentlyPlayedItems as MusicItemCollection<RecentlyPlayedMusicItem>:
            for itemIndex in recentlyPlayedItems.indices {
                switch recentlyPlayedItems[itemIndex] {
                case .album(let album):
                    albumItem(album: album, albumIndex: itemIndex)
                case .station(let station):
                    stationItem(station: station, stationIndex: itemIndex)
                case .playlist(let playlist):
                    playlistItem(playlist: playlist, playlistIndex: itemIndex)
                default: break
                }
                if itemIndex >= maxItemsDisplayed {
                    break
                }
            }
        case let recommendedItems as MusicItemCollection<MusicPersonalRecommendation>:
            recommendationItems(recommendations: recommendedItems)
        default: break
        }
    }

    private func songItems(songs: MusicItemCollection<Song>) {
        for songIndex in songs.indices {
            itemIndicesPlane.putString("\(songIndex)", at: (x: 0, y: 2 + Int32(songIndex) * 5))
            guard
                let item = SongItemPage(
                    in: plane,
                    state: .init(
                        absX: 2,
                        absY: 1 + Int32(songIndex) * 5,
                        width: state.width - 3,
                        height: 5
                    ),
                    colorConfig: colorConfig.songItem,
                    item: songs[songIndex]
                )
            else { return }
            self.searchCache.append(item)
            if songIndex >= maxItemsDisplayed {
                break
            }
        }
    }

    private func albumItems(albums: MusicItemCollection<Album>) {
        for albumIndex in albums.indices {
            albumItem(album: albums[albumIndex], albumIndex: albumIndex)
            if albumIndex >= maxItemsDisplayed {
                break
            }
        }
    }

    private func albumItem(album: Album, albumIndex: Int) {
        itemIndicesPlane.putString("\(albumIndex)", at: (x: 0, y: 2 + Int32(albumIndex) * 5))
        guard
            let item = AlbumItemPage(
                in: plane,
                state: .init(
                    absX: 2,
                    absY: 1 + Int32(albumIndex) * 5,
                    width: state.width - 3,
                    height: 5
                ),
                colorConfig: colorConfig.albumItem,
                item: album
            )
        else { return }
        self.searchCache.append(item)
    }

    private func artistItems(artists: MusicItemCollection<Artist>) async {
        for artistIndex in artists.indices {
            await artistItem(artist: artists[artistIndex], artistIndex: artistIndex)
            if artistIndex >= maxItemsDisplayed {
                break
            }
        }
    }

    private func artistItem(artist: Artist, artistIndex: Int) async {
        itemIndicesPlane.putString("\(artistIndex)", at: (x: 0, y: 2 + Int32(artistIndex) * 5))
        guard
            let item = await ArtistItemPage(
                in: plane,
                state: .init(
                    absX: 2,
                    absY: 1 + Int32(artistIndex) * 5,
                    width: state.width - 3,
                    height: 5
                ),
                colorConfig: colorConfig.artistItem,
                item: artist
            )
        else { return }
        self.searchCache.append(item)
    }

    private func playlistItems(playlists: MusicItemCollection<Playlist>) {
        for playlistIndex in playlists.indices {
            playlistItem(playlist: playlists[playlistIndex], playlistIndex: playlistIndex)
            if playlistIndex >= maxItemsDisplayed {
                break
            }
        }
    }

    private func playlistItem(playlist: Playlist, playlistIndex: Int) {
        itemIndicesPlane.putString("\(playlistIndex)", at: (x: 0, y: 2 + Int32(playlistIndex) * 5))
        guard
            let item = PlaylistItemPage(
                in: plane,
                state: .init(
                    absX: 2,
                    absY: 1 + Int32(playlistIndex) * 5,
                    width: state.width - 3,
                    height: 5
                ),
                colorConfig: colorConfig.playlistItem,
                item: playlist
            )
        else { return }
        self.searchCache.append(item)
    }

    private func stationItems(stations: MusicItemCollection<Station>) {
        for stationIndex in stations.indices {
            stationItem(station: stations[stationIndex], stationIndex: stationIndex)
            if stationIndex >= maxItemsDisplayed {
                break
            }
        }
    }

    private func stationItem(station: Station, stationIndex: Int) {
        itemIndicesPlane.putString("\(stationIndex)", at: (x: 0, y: 2 + Int32(stationIndex) * 5))
        guard
            let item = StationItemPage(
                in: plane,
                state: .init(
                    absX: 2,
                    absY: 1 + Int32(stationIndex) * 5,
                    width: state.width - 3,
                    height: 5
                ),
                colorConfig: colorConfig.stationItem,
                item: station
            )
        else { return }
        self.searchCache.append(item)
    }

    private func recommendationItems(recommendations: MusicItemCollection<MusicPersonalRecommendation>) {
        for recommendationIndex in recommendations.indices {
            recommendationItem(
                recommendation: recommendations[recommendationIndex],
                recommendationIndex: recommendationIndex
            )
            if recommendationIndex >= maxItemsDisplayed {
                break
            }
        }
    }

    private func recommendationItem(recommendation: MusicPersonalRecommendation, recommendationIndex: Int) {
        itemIndicesPlane.putString("\(recommendationIndex)", at: (x: 0, y: 2 + Int32(recommendationIndex) * 5))
        guard
            let item = RecommendationItemPage(
                in: plane,
                state: .init(
                    absX: 2,
                    absY: 1 + Int32(recommendationIndex) * 5,
                    width: state.width - 3,
                    height: 5
                ),
                colorConfig: colorConfig.recommendationItem,
                item: recommendation
            )
        else { return }
        self.searchCache.append(item)
    }

}
