import Foundation
import MusadoraKit
import notcurses

public actor SearchPage: Page {

    private let plane: Plane

    private let output: Output

    private var state: PageState

    private var lastSearchTime: Date
    private var searchCache: [Page]

    private var maxItemsDisplayed: Int {
        (Int(self.state.height) - 4) / 6
    }

    public func onResize(newPageState: PageState) async {
        self.state = newPageState
        ncplane_move_yx(plane.ncplane, state.absY, state.absX)
        ncplane_resize_simple(plane.ncplane, state.height, state.width)
        for item in searchCache {
            await (item as! SongItemPage).destroy()
        }
        self.searchCache = []
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

    public init?(stdPlane: Plane, state: PageState) {
        self.state = state
        guard
            let plane = Plane(
                in: stdPlane,
                opts: .init(
                    x: 30,
                    y: 0,
                    width: state.width,
                    height: state.height - 3,
                    debugID: "SEARCH_PAGE",
                    flags: [.fixed]
                )
            )
        else {
            return nil
        }
        self.plane = plane
        self.output = .init(plane: plane)
        self.searchCache = []
        self.lastSearchTime = .now
    }

    public func render() async {

        ncplane_erase(plane.ncplane)

        if let result = SearchManager.shared.lastSearchResults[
            .catalogSearchSongs
        ], let searchPhrase = result.searchPhrase {
            output.windowBorder(
                name: "Search songs: \(searchPhrase)",
                state: state
            )
        } else {
            output.windowBorder(name: "Search songs:", state: state)
        }

        if let result = SearchManager.shared.lastSearchResults[
            .catalogSearchSongs
        ] {
            if searchCache.isEmpty || lastSearchTime != result.timestamp {
                for item in searchCache {
                    await (item as! SongItemPage).destroy()
                }
                searchCache = []
                lastSearchTime = result.timestamp
                let songs = result.result as! MusicItemCollection<Song>
                for songIndex in songs.indices {
                    guard
                        let item = SongItemPage(
                            in: plane,
                            state: .init(
                                absX: 1,
                                absY: 3 + Int32(songIndex) * 6,
                                width: state.width - 2,
                                height: 6
                            ),
                            item: songs[songIndex]
                        )
                    else { continue }
                    self.searchCache.append(item)
                }
                var counter = 0
                for itemIndex in searchCache.indices {
                    if counter >= maxItemsDisplayed {
                        break
                    }
                    await searchCache[itemIndex].render()
                    counter += 1
                }
            }
        }
    }

}

public struct SearchItem {

    public let plane: Plane

    public let type: MusicItem.Type

    public let item: any MusicItem

}
