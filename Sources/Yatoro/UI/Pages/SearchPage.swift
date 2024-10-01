import Foundation
import Logging
import MusadoraKit
import notcurses

public actor SearchPage: Page {

    private let plane: Plane
    private let logger: Logger?

    private let output: Output

    private var state: PageState

    private var lastSearchTime: Date
    private var searchCache: [Page]

    public func onResize(newPageState: PageState) async {
        self.state = newPageState
        ncplane_move_yx(plane.ncplane, state.absY, state.absX)
        ncplane_resize_simple(plane.ncplane, state.height, state.width)
    }

    public func getPageState() async -> PageState {
        self.state
    }

    public func getMaxDimensions() async -> (width: UInt32, height: UInt32)? {
        nil
    }

    public func getMinDimensions() async -> (width: UInt32, height: UInt32) {
        (23, 17)
    }

    public init?(stdPlane: Plane, state: PageState, logger: Logger?) {
        self.state = state
        guard
            let plane = Plane(
                in: stdPlane,
                opts: .init(
                    x: 30,
                    y: 0,
                    width: state.width,
                    height: state.height,
                    debugID: "SEARCH_PAGE"
                        // flags: [.verticalScrolling]
                ),
                logger: logger
            )
        else {
            return nil
        }
        self.plane = plane
        self.logger = logger
        self.output = .init(plane: plane)
        self.searchCache = []
        self.lastSearchTime = .now
    }

    public func render() async {

        output.putString("Search songs:", at: (0, 0))

        if let result = SearchManager.shared.lastSearchResults[
            .catalogSearchSongs
        ] {
            if searchCache.isEmpty || lastSearchTime != result.timestamp {
                for item in searchCache {
                    await (item as! SongSearchItemPage).destroy()
                }
                searchCache = []
                lastSearchTime = result.timestamp
                let songs = result.result as! MusicItemCollection<Song>
                for songIndex in songs.indices {
                    guard
                        let item = SongSearchItemPage(
                            in: plane,
                            position: songIndex,
                            item: songs[songIndex],
                            logger: logger
                        )
                    else { continue }
                    self.searchCache.append(item)
                }
                for item in searchCache {
                    await item.render()
                }
            }
        }
    }

    private func renderSong(item: Song, position: Int) -> SearchItem? {
        nil
    }

    private func renderAlbum(item: Album, position: Int) {
    }

    private func renderStations(items: [Station]) {

    }

    private func renderPlaylists(items: [Playlist]) {

    }

    private func renderArtists(items: [Artist]) {

    }

    private func renderRadioShows(items: [RadioShow]) {

    }

}

public struct SearchItem {

    public let plane: Plane

    public let type: MusicItem.Type

    public let item: any MusicItem

}
