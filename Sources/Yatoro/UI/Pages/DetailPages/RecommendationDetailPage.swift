import SwiftNotCurses

@MainActor
public class RecommendationDetailPage: DestroyablePage {

    private var state: PageState

    private let recommendationDescription: RecommendationDescriptionResult

    private var plane: Plane

    private var borderPlane: Plane

    private var recommendationTitlePlane: Plane?  // Name of the recommendation

    private var playlistsTitlePlane: Plane?  // "Playlists:"
    private var playlistIndicesPlane: Plane?
    private var playlistItemPages: [PlaylistItemPage?]

    private var stationsTitlePlane: Plane?  // "Stations:"
    private var stationIndicesPlane: Plane?
    private var stationItemPages: [StationItemPage?]

    private var albumsTitlePlane: Plane?  // "Albums:"
    private var albumIndicesPlane: Plane?
    private var albumItemPages: [AlbumItemPage?]

    private var maxItemsDisplayed: Int {
        Int(state.height - 8) / 5
    }

    public init?(
        in stdPlane: Plane,
        state: PageState,
        recommendationDescription: RecommendationDescriptionResult
    ) {
        self.state = state
        self.recommendationDescription = recommendationDescription

        guard
            let plane = Plane(
                in: stdPlane,
                state: state,
                debugID: "RDP"
            )
        else {
            return nil
        }
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
                debugID: "RDBP"
            )
        else {
            return nil
        }
        self.borderPlane = borderPlane

        if let title = recommendationDescription.recommendation.title {
            guard
                let recommendationTitlePlane = Plane(
                    in: plane,
                    state: .init(
                        absX: 4,
                        absY: 0,
                        width: UInt32(title.count),
                        height: 1
                    ),
                    debugID: "RDTP"
                )
            else {
                return nil
            }
            self.recommendationTitlePlane = recommendationTitlePlane
        }

        self.playlistsTitlePlane = Plane(
            in: plane,
            state: .init(
                absX: 2,
                absY: 2,
                width: 10,
                height: 1
            ),
            debugID: "RDPPTP"
        )

        let oneThirdWidth = Int32(state.width) / 3

        self.stationsTitlePlane = Plane(
            in: plane,
            state: .init(
                absX: oneThirdWidth + 2,
                absY: 2,
                width: 9,
                height: 1
            ),
            debugID: "RDPSTP"
        )

        self.albumsTitlePlane = Plane(
            in: plane,
            state: .init(
                absX: oneThirdWidth * 2 + 2,
                absY: 2,
                width: 7,
                height: 1
            ),
            debugID: "RDPALTP"
        )

        playlistItemPages = []
        stationItemPages = []
        albumItemPages = []

        loadPlaylists()
        loadStations()
        loadAlbums()

        updateColors()

    }

    private func loadPlaylists() {
        guard let playlists = recommendationDescription.playlists else {
            return
        }
        self.playlistIndicesPlane = Plane(
            in: plane,
            state: .init(
                absX: 2,
                absY: 4,
                width: 2,
                height: 5 * UInt32(min(maxItemsDisplayed + 1, playlists.count))
            ),
            debugID: "RDPPIP"
        )
        for playlistIndex in 0..<playlists.count {
            let playlistItem = PlaylistItemPage(
                in: borderPlane,
                state: .init(
                    absX: 4,
                    absY: 4 + Int32(playlistIndex) * 5,
                    width: state.width / 3 - 6,
                    height: 5
                ),
                item: playlists[playlistIndex],
                type: .recommendationDetail
            )
            self.playlistItemPages.append(playlistItem)
        }

    }

    private func loadStations() {
        guard let stations = recommendationDescription.stations else {
            return
        }
        let oneThirdWidth = Int32(state.width) / 3
        self.stationIndicesPlane = Plane(
            in: plane,
            state: .init(
                absX: oneThirdWidth + 2,
                absY: 4,
                width: 2,
                height: 5 * UInt32(min(maxItemsDisplayed + 1, stations.count))
            ),
            debugID: "RDPSIP"
        )
        for stationIndex in 0..<stations.count {
            if maxItemsDisplayed < stationIndex {
                break
            }
            Task {
                let stationItem = StationItemPage(
                    in: borderPlane,
                    state: .init(
                        absX: oneThirdWidth + 4,
                        absY: 4 + 5 * Int32(stationIndex),
                        width: UInt32(oneThirdWidth) - 6,
                        height: 5
                    ),
                    item: stations[stationIndex],
                    type: .recommendationDetail
                )
                self.stationItemPages.append(stationItem)
            }
        }
    }

    private func loadAlbums() {
        guard let albums = recommendationDescription.albums else {
            return
        }
        let oneThirdWidth = Int32(state.width) / 3
        self.albumIndicesPlane = Plane(
            in: plane,
            state: .init(
                absX: oneThirdWidth * 2 + 2,
                absY: 4,
                width: 2,
                height: 5 * UInt32(min(maxItemsDisplayed + 1, albums.count))
            ),
            debugID: "RDPAIP"
        )
        for albumIndex in 0..<albums.count {
            if maxItemsDisplayed < albumIndex {
                break
            }
            Task {
                let albumItem = AlbumItemPage(
                    in: borderPlane,
                    state: .init(
                        absX: oneThirdWidth * 2 + 4,
                        absY: 4 + 5 * Int32(albumIndex),
                        width: UInt32(oneThirdWidth) - 6,
                        height: 5
                    ),
                    item: albums[albumIndex],
                    type: .recommendationDetailPage
                )
                self.albumItemPages.append(albumItem)
            }
        }
    }

    public func destroy() async {
        self.plane.erase()
        self.plane.destroy()

        self.borderPlane.erase()
        self.borderPlane.destroy()

        self.recommendationTitlePlane?.erase()
        self.recommendationTitlePlane?.destroy()

        self.playlistsTitlePlane?.erase()
        self.playlistsTitlePlane?.destroy()

        self.playlistIndicesPlane?.erase()
        self.playlistIndicesPlane?.destroy()

        self.stationsTitlePlane?.erase()
        self.stationsTitlePlane?.destroy()

        self.stationIndicesPlane?.erase()
        self.stationIndicesPlane?.destroy()

        self.albumsTitlePlane?.erase()
        self.albumsTitlePlane?.destroy()

        self.albumIndicesPlane?.erase()
        self.albumIndicesPlane?.destroy()

        for playlistPage in self.playlistItemPages {
            await playlistPage?.destroy()
        }

        for stationPage in self.stationItemPages {
            await stationPage?.destroy()
        }

        for albumPage in self.albumItemPages {
            await albumPage?.destroy()
        }
    }

    public func render() async {
    }

    public func updateColors() {
        let colorConfig = Config.shared.ui.colors.recommendationDetail

        self.plane.setColorPair(colorConfig.page)
        self.plane.blank()

        self.borderPlane.setColorPair(colorConfig.border)
        self.borderPlane.windowBorder(width: state.width, height: state.height)

        if let title = self.recommendationDescription.recommendation.title {
            self.recommendationTitlePlane?.setColorPair(colorConfig.recommendationTitle)
            self.recommendationTitlePlane?.putString(title, at: (0, 0))
        }

        if let playlists = self.recommendationDescription.playlists, !playlists.isEmpty {
            self.playlistsTitlePlane?.setColorPair(colorConfig.playlistsText)
            self.playlistsTitlePlane?.putString("Playlists:", at: (0, 0))

            self.playlistIndicesPlane?.setColorPair(colorConfig.playlistIndices)
            for playlistIndex in 0..<playlists.count {
                if maxItemsDisplayed < playlistIndex {
                    break
                }
                self.playlistIndicesPlane?.putString("p\(playlistIndex)", at: (0, 2 + Int32(playlistIndex) * 5))
            }
        }

        if let stations = self.recommendationDescription.stations, !stations.isEmpty {
            self.stationsTitlePlane?.setColorPair(colorConfig.stationsText)
            self.stationsTitlePlane?.putString("Stations:", at: (0, 0))

            self.stationIndicesPlane?.setColorPair(colorConfig.stationIndices)
            for stationIndex in 0..<stations.count {
                if maxItemsDisplayed < stationIndex {
                    break
                }
                self.stationIndicesPlane?.putString("s\(stationIndex)", at: (0, 2 + Int32(stationIndex) * 5))
            }
        }

        if let albums = self.recommendationDescription.albums, !albums.isEmpty {
            self.albumsTitlePlane?.setColorPair(colorConfig.albumsText)
            self.albumsTitlePlane?.putString("Albums:", at: (0, 0))

            self.albumIndicesPlane?.setColorPair(colorConfig.albumIndices)
            for albumIndex in 0..<albums.count {
                if maxItemsDisplayed < albumIndex {
                    break
                }
                self.albumIndicesPlane?.putString("a\(albumIndex)", at: (0, 2 + Int32(albumIndex) * 5))
            }
        }

        for page in playlistItemPages {
            page?.updateColors()
        }
        for page in stationItemPages {
            page?.updateColors()
        }
        for page in albumItemPages {
            page?.updateColors()
        }
    }

    public func onResize(newPageState: PageState) async {
        self.state = newPageState

        plane.updateByPageState(state)

        borderPlane.updateByPageState(.init(absX: 0, absY: 0, width: state.width, height: state.height))
        borderPlane.erase()
        borderPlane.windowBorder(width: state.width, height: state.height)

    }

    public func getPageState() async -> PageState { state }

    public func getMinDimensions() async -> (width: UInt32, height: UInt32) { (23, 23) }

    public func getMaxDimensions() async -> (width: UInt32, height: UInt32)? { nil }

}
