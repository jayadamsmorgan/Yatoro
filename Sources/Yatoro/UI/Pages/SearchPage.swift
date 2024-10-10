import Foundation
import MusicKit
import SwiftNotCurses

@MainActor
public class SearchPage: Page {

    private let plane: Plane

    private var state: PageState

    private var lastSearchTime: Date
    private var searchCache: [Page]

    private var maxItemsDisplayed: Int {
        (Int(self.state.height) - 3) / 6
    }

    public func onResize(newPageState: PageState) async {
        self.state = newPageState
        plane.updateByPageState(state)
        for case let item as SongItemPage in searchCache {
            await item.destroy()
        }
        self.searchCache = []
    }

    public func getPageState() async -> PageState { self.state }

    public func getMaxDimensions() async -> (width: UInt32, height: UInt32)? { nil }

    public func getMinDimensions() async -> (width: UInt32, height: UInt32) { (23, 17) }

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
        self.searchCache = []
        self.lastSearchTime = .now
    }

    public func render() async {

        plane.erase()

        if let result = SearchManager.shared.lastSearchResults[.catalogSearchSongs],
            let searchPhrase = result.searchPhrase
        {
            plane.windowBorder(
                name: "Search songs: \(searchPhrase)",
                width: state.width,
                height: state.height
            )
        } else {
            plane.windowBorder(
                name: "Search songs:",
                width: state.width,
                height: state.height
            )
        }

        guard let result = SearchManager.shared.lastSearchResults[.catalogSearchSongs] else {
            return
        }
        guard searchCache.isEmpty || lastSearchTime != result.timestamp else {
            return
        }

        for case let item as SongItemPage in searchCache {
            await item.destroy()
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
        for itemIndex in searchCache.indices {
            if itemIndex >= maxItemsDisplayed {
                break
            }
            await searchCache[itemIndex].render()
        }

    }

}
