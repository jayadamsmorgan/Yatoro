import SwiftNotCurses

@MainActor
public class SongDetailPage: DestroyablePage {

    private var state: PageState

    private let songDescription: SongDescriptionResult

    private var plane: Plane

    private var borderPlane: Plane

    private var artworkPlane: Plane
    private var artworkVisual: Visual?

    private var songTitlePlane: Plane  // Name of the song
    private var artistsTitlePlane: Plane?  // "Artists:"
    private var artistsIndicesPlane: Plane?  // Indexes of artists

    private var artistItemPages: [ArtistItemPage?]
    private var albumItemPage: AlbumItemPage?
    private var albumTitlePlane: Plane?  // "Album:"
    private var albumIndexPlane: Plane?

    // TODO: Maybe consider displaying lyrics if they're present, idk

    public init?(
        in stdPlane: Plane,
        state: PageState,
        songDescription: SongDescriptionResult
    ) {
        self.state = state
        self.songDescription = songDescription

        guard
            let plane = Plane(
                in: stdPlane,
                state: state,
                debugID: "SDP"
            )
        else {
            return nil
        }
        self.plane = plane
        plane.blank()

        guard
            let artworkPlane = Plane(
                in: plane,
                state: .init(
                    absX: 0,
                    absY: 0,
                    width: 1,
                    height: 1
                ),
                debugID: "SDPAP"
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
                debugID: "SDBP"
            )
        else {
            return nil
        }
        borderPlane.windowBorder(width: state.width, height: state.height)
        self.borderPlane = borderPlane

        let title = songDescription.song.title
        guard
            let songTitlePlane = Plane(
                in: plane,
                state: .init(
                    absX: 4,
                    absY: 2,
                    width: UInt32(title.count),
                    height: 1
                ),
                debugID: "SDTP"
            )
        else {
            return nil
        }
        songTitlePlane.putString(title, at: (0, 0))
        self.songTitlePlane = songTitlePlane

        let oneThirdWidth = Int32(state.width) / 3

        self.artistsTitlePlane = Plane(
            in: plane,
            state: .init(
                absX: oneThirdWidth * 2 + 2,
                absY: 2,
                width: 8,
                height: 1
            ),
            debugID: "SDPARTP"
        )
        artistsTitlePlane?.putString("Artists:", at: (0, 0))

        self.albumTitlePlane = Plane(
            in: plane,
            state: .init(
                absX: oneThirdWidth + 2,
                absY: 2,
                width: 6,
                height: 1
            ),
            debugID: "SDPALTP"
        )
        albumTitlePlane?.putString("Album:", at: (0, 0))

        artistItemPages = []

        loadArtists()

        loadAlbum()

        loadArtwork()

    }

    private func loadAlbum() {
        if let album = songDescription.album {
            Task {
                self.albumItemPage = AlbumItemPage(
                    in: plane,
                    state: .init(
                        absX: Int32(state.width) / 3 + 4,
                        absY: 4,
                        width: state.width / 3 - 6,
                        height: 5
                    ),
                    item: album
                )
                self.albumIndexPlane = Plane(
                    in: plane,
                    state: .init(
                        absX: Int32(state.width) / 3 + 2,
                        absY: 4,
                        width: 2,
                        height: 5
                    ),
                    debugID: "SDPALIP"
                )
                self.albumIndexPlane?.putString("a0", at: (0, 2))
            }
        }
    }

    private func loadArtists() {
        if let artists = songDescription.artists {
            if artists.count > 0 {
                self.artistsIndicesPlane = Plane(
                    in: plane,
                    state: .init(
                        absX: Int32(state.width) / 3 * 2 + 2,
                        absY: 4,
                        width: 2,
                        height: 5 * UInt32(artists.count)
                    ),
                    debugID: "SDPARIP"
                )
            }
            for artistIndex in 0..<artists.count {
                Task {
                    let artistItem = await ArtistItemPage(
                        in: plane,
                        state: .init(
                            absX: Int32(state.width) / 3 * 2 + 4,
                            absY: 4 + Int32(artistIndex * 5),
                            width: state.width / 3 - 6,
                            height: 5
                        ),
                        item: artists[artistIndex]
                    )
                    artistItemPages.append(artistItem)
                    artistsIndicesPlane?.putString("w\(artistIndex)", at: (0, 2 + Int32(artistIndex * 5)))
                }
            }
        }
    }

    private func loadArtwork() {
        Task {
            if let url = songDescription.song.artwork?.url(
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
                            "Now Playing: Successfully obtained artwork RGBA byte array with count: \(pixelArray.count)"
                        )
                        Task { @MainActor in
                            self.handleArtwork(pixelArray: pixelArray)
                        }
                    } else {
                        await logger?.error("Now Playing: Failed to get artwork RGBA byte array.")
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

        self.songTitlePlane.erase()
        self.songTitlePlane.destroy()

        self.albumTitlePlane?.erase()
        self.albumTitlePlane?.destroy()

        self.albumIndexPlane?.erase()
        self.albumIndexPlane?.blank()
        self.albumIndexPlane?.destroy()

        self.artistsTitlePlane?.erase()
        self.artistsTitlePlane?.destroy()

        self.artistsIndicesPlane?.erase()
        self.artistsIndicesPlane?.destroy()

        await self.albumItemPage?.destroy()
        for artistPage in self.artistItemPages {
            await artistPage?.destroy()
        }
    }

    public func render() async {

    }

    public func updateColors() {

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
