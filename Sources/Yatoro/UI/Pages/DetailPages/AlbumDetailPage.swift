import SwiftNotCurses

@MainActor
public class AlbumDetailPage: DestroyablePage {

    private var state: PageState

    private let albumDescription: AlbumDescriptionResult

    private var plane: Plane

    private var borderPlane: Plane

    private var artworkPlane: Plane
    private var artworkVisual: Visual?

    private var albumTitlePlane: Plane?  // Name of the album

    private var artistsTitlePlane: Plane?  // "Artists:"
    private var artistsIndicesPlane: Plane?  // Indices of artists

    private var songsTitlePlane: Plane?  // "Songs:"
    private var songIndicesPlane: Plane?  // Indices of songs

    private var artistItemPages: [ArtistItemPage?]
    private var songItemPages: [SongItemPage?]

    private var maxItemsDisplayed: Int {
        Int(state.height - 8) / 5
    }

    public init?(
        in stdPlane: Plane,
        state: PageState,
        albumDescription: AlbumDescriptionResult
    ) {
        self.state = state
        self.albumDescription = albumDescription

        guard
            let plane = Plane(
                in: stdPlane,
                state: state,
                debugID: "ADP"
            )
        else {
            return nil
        }
        self.plane = plane

        guard
            let artworkPlane = Plane(
                in: plane,
                state: .init(
                    absX: 0,
                    absY: 0,
                    width: 1,
                    height: 1
                ),
                debugID: "ADPAP"
            )
        else {
            return nil
        }
        self.artworkPlane = artworkPlane

        guard
            let borderPlane = Plane(
                in: plane,
                state: .init(
                    absX: 0,
                    absY: 0,
                    width: state.width,
                    height: state.height
                ),
                debugID: "ADBP"
            )
        else {
            return nil
        }
        self.borderPlane = borderPlane

        let title = albumDescription.album.title
        guard
            let albumTitlePlane = Plane(
                in: plane,
                state: .init(
                    absX: 4,
                    absY: 2,
                    width: UInt32(title.count),
                    height: 1
                ),
                debugID: "ADTP"
            )
        else {
            return nil
        }
        self.albumTitlePlane = albumTitlePlane

        let oneThirdWidth = Int32(state.width) / 3

        self.artistsTitlePlane = Plane(
            in: plane,
            state: .init(
                absX: oneThirdWidth * 2 + 2,
                absY: 2,
                width: 8,
                height: 1
            ),
            debugID: "ADPARTP"
        )

        self.songsTitlePlane = Plane(
            in: plane,
            state: .init(
                absX: oneThirdWidth + 2,
                absY: 2,
                width: 6,
                height: 1
            ),
            debugID: "ADPALTP"
        )

        artistItemPages = []
        songItemPages = []

        loadSongs()

        loadArtists()

        loadArtwork()

        updateColors()

    }

    private func loadSongs() {
        let songs = albumDescription.songs
        if !songs.isEmpty {
            self.songIndicesPlane = Plane(
                in: plane,
                state: .init(
                    absX: Int32(state.width) / 3 + 2,
                    absY: 4,
                    width: 2,
                    height: 5 * UInt32(min(maxItemsDisplayed + 1, songs.count))
                ),
                debugID: "ADPSIP"
            )
            for songIndex in 0..<songs.count {
                if maxItemsDisplayed < songIndex {
                    break
                }
                Task {
                    let songItem = SongItemPage(
                        in: borderPlane,
                        state: .init(
                            absX: Int32(state.width) / 3 + 4,
                            absY: 4 + Int32(songIndex) * 5,
                            width: state.width / 3 - 6,
                            height: 5
                        ),
                        type: .albumDetailPage,
                        item: songs[songIndex]
                    )
                    self.songItemPages.append(songItem)
                }
            }
        }
    }

    private func loadArtists() {
        if let artists = albumDescription.artists, !artists.isEmpty {
            self.artistsIndicesPlane = Plane(
                in: plane,
                state: .init(
                    absX: Int32(state.width) / 3 * 2 + 2,
                    absY: 4,
                    width: 2,
                    height: 5 * UInt32(min(maxItemsDisplayed + 1, artists.count))
                ),
                debugID: "ADPARIP"
            )
            for artistIndex in 0..<artists.count {
                if maxItemsDisplayed < artistIndex {
                    break
                }
                Task {
                    let artistItem = await ArtistItemPage(
                        in: borderPlane,
                        state: .init(
                            absX: Int32(state.width) / 3 * 2 + 4,
                            absY: 4 + Int32(artistIndex * 5),
                            width: state.width / 3 - 6,
                            height: 5
                        ),
                        item: artists[artistIndex],
                        type: .albumDetailPage
                    )
                    artistItemPages.append(artistItem)
                }
            }
        }
    }

    private func loadArtwork() {
        Task {
            if let url = albumDescription.album.artwork?.url(
                width: Int(Config.shared.ui.artwork.width),
                height: Int(Config.shared.ui.artwork.height)
            ) {
                downloadImageAndConvertToRGBA(
                    url: url,
                    width: Int(Config.shared.ui.artwork.width),
                    heigth: Int(Config.shared.ui.artwork.height)
                ) { pixelArray in
                    if let pixelArray = pixelArray {
                        await logger?.debug(
                            "AlbumDetailPage: Successfully obtained artwork RGBA byte array with count: \(pixelArray.count)"
                        )
                        Task { @MainActor in
                            self.handleArtwork(pixelArray: pixelArray)
                        }
                    } else {
                        await logger?.error("AlbumDetailPage: Failed to get artwork RGBA byte array.")
                    }
                }
            }
        }
    }

    func handleArtwork(pixelArray: [UInt8]) {
        let artworkPlaneWidth = state.width / 3 - 5
        let artworkPlaneHeight = artworkPlaneWidth / 2 - 1
        if artworkPlaneHeight > self.state.height - 12 {  // TODO: fix
            self.artworkVisual?.destroy()
            self.artworkPlane.updateByPageState(
                .init(
                    absX: 0,
                    absY: 0,
                    width: 1,
                    height: 1
                )
            )
            return
        }
        self.artworkPlane.updateByPageState(
            .init(
                absX: 4,
                absY: 6,
                width: artworkPlaneWidth,
                height: artworkPlaneHeight
            )
        )
        self.artworkVisual?.destroy()
        self.artworkVisual = Visual(
            in: UI.notcurses!,
            width: Int32(Config.shared.ui.artwork.width),
            height: Int32(Config.shared.ui.artwork.height),
            from: pixelArray,
            for: self.artworkPlane
        )
        self.artworkVisual?.render()
    }

    public func destroy() async {
        self.plane.erase()
        self.plane.destroy()

        self.borderPlane.erase()
        self.borderPlane.destroy()

        self.artworkVisual?.destroy()
        self.artworkPlane.erase()
        self.artworkPlane.destroy()

        self.albumTitlePlane?.erase()
        self.albumTitlePlane?.destroy()

        self.artistsTitlePlane?.erase()
        self.artistsTitlePlane?.destroy()
        self.artistsIndicesPlane?.erase()
        self.artistsIndicesPlane?.destroy()

        self.songIndicesPlane?.erase()
        self.songIndicesPlane?.destroy()

        self.songsTitlePlane?.erase()
        self.songsTitlePlane?.destroy()

        for artistPage in self.artistItemPages {
            await artistPage?.destroy()
        }
        for songPage in self.songItemPages {
            await songPage?.destroy()
        }
    }

    public func render() async {

    }

    public func updateColors() {
        let colorConfig = Config.shared.ui.colors.albumDetail

        self.plane.setColorPair(colorConfig.page)
        self.plane.blank()

        self.borderPlane.setColorPair(colorConfig.border)
        self.borderPlane.windowBorder(width: state.width, height: state.height)

        self.albumTitlePlane?.setColorPair(colorConfig.albumTitle)
        self.albumTitlePlane?.putString(albumDescription.album.title, at: (0, 0))

        self.songsTitlePlane?.setColorPair(colorConfig.songsText)
        self.songIndicesPlane?.setColorPair(colorConfig.songsIndices)
        let songs = albumDescription.songs
        if !songs.isEmpty {
            self.songsTitlePlane?.putString("Songs:", at: (0, 0))
            for songIndex in 0..<songs.count {
                if maxItemsDisplayed < songIndex {
                    break
                }
                self.songIndicesPlane?.putString("s\(songIndex)", at: (0, 2 + Int32(songIndex * 5)))
            }
        }

        self.artistsTitlePlane?.setColorPair(colorConfig.artistsText)
        self.artistsIndicesPlane?.setColorPair(colorConfig.artistIndices)
        if let artists = albumDescription.artists, !artists.isEmpty {
            self.artistsTitlePlane?.putString("Artists:", at: (0, 0))
            for artistIndex in 0..<artists.count {
                if maxItemsDisplayed < artistIndex {
                    break
                }
                self.artistsIndicesPlane?.putString("w\(artistIndex)", at: (0, 2 + Int32(artistIndex * 5)))
            }
        }

        for page in artistItemPages {
            page?.updateColors()
        }
        for page in songItemPages {
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
