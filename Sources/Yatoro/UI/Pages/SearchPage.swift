import Foundation
import MusicKit
import SwiftNotCurses

@MainActor
public class SearchPage: Page {

    private let plane: Plane
    private let pageNamePlane: Plane
    private let borderPlane: Plane
    private let searchPhrasePlane: Plane

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

        for case let item as SongItemPage in searchCache {
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

        self.searchCache = []
        self.lastSearchTime = .now
        self.colorConfig = colorConfig
    }

    public func render() async {

        if let result = SearchManager.shared.lastSearchResults[.catalogSearchSongs],
            let searchPhrase = result.searchPhrase
        {
            pageNamePlane.width = 14
            pageNamePlane.putString("Catalog songs:", at: (0, 0))
            searchPhrasePlane.updateByPageState(
                .init(absX: 17, absY: 0, width: UInt32(searchPhrase.count - 1), height: 1)
            )
            searchPhrasePlane.putString(searchPhrase, at: (0, 0))

            await update(result: result)

        } else if let result = SearchManager.shared.lastSearchResults[.librarySearchSongs],
            let searchPhrase = result.searchPhrase
        {
            pageNamePlane.width = 14
            pageNamePlane.putString("Library songs:", at: (0, 0))
            searchPhrasePlane.updateByPageState(
                .init(absX: 17, absY: 0, width: UInt32(searchPhrase.count - 1), height: 1)
            )
            searchPhrasePlane.putString(searchPhrase, at: (0, 0))

            await update(result: result)

        } else if let result = SearchManager.shared.lastSearchResults[.recommended] {
            pageNamePlane.width = 11
            pageNamePlane.putString("Recommended", at: (0, 0))
            searchPhrasePlane.updateByPageState(.init(absX: 2, absY: 0, width: 1, height: 1))
            searchPhrasePlane.erase()

            await update(result: result)

        } else if let result = SearchManager.shared.lastSearchResults[.recentlyPlayedSongs] {
            pageNamePlane.width = 15
            pageNamePlane.putString("Recently Played", at: (0, 0))
            searchPhrasePlane.updateByPageState(.init(absX: 2, absY: 0, width: 1, height: 1))
            searchPhrasePlane.erase()

            await update(result: result)

        } else {
            pageNamePlane.width = 6
            pageNamePlane.putString("Search", at: (0, 0))
            searchPhrasePlane.updateByPageState(.init(absX: 2, absY: 0, width: 1, height: 1))
            searchPhrasePlane.erase()
        }
    }

    private func update(result: SearchResult) async {
        guard searchCache.isEmpty || lastSearchTime != result.timestamp else {
            return
        }
        logger?.debug("Search UI update.")

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
                        absY: 1 + Int32(songIndex) * 5,
                        width: state.width - 2,
                        height: 5
                    ),
                    colorConfig: colorConfig.songItem,
                    item: songs[songIndex]
                )
            else { continue }
            self.searchCache.append(item)
            if songIndex >= maxItemsDisplayed {
                break
            }
        }
    }

}
