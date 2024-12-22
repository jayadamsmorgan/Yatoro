import SwiftNotCurses

@MainActor
public class PlaylistDetailPage: DestroyablePage {

    private var state: PageState

    private let playlistDescription: PlaylistDescriptionResult

    private var plane: Plane

    private var borderPlane: Plane

    private var artworkPlane: Plane
    private var artworkVisual: Visual?

    private var playlistTitlePlane: Plane?  // Name of the playlist

    private var songsTitlePlane: Plane?  // "Songs:"
    private var songIndicesPlane: Plane?  // Indices of songs

    private var songItemPages: [SongItemPage?]

    private var maxItemsDisplayed: Int {
        Int(state.height - 8) / 5
    }

    public init?(
        in stdPlane: Plane,
        state: PageState,
        playlistDescription: PlaylistDescriptionResult
    ) {
        self.state = state
        self.playlistDescription = playlistDescription

        guard
            let plane = Plane(
                in: stdPlane,
                state: state,
                debugID: "PDP"
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
                debugID: "PDPAP"
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
                debugID: "PDBP"
            )
        else {
            return nil
        }
        self.borderPlane = borderPlane

        let title = playlistDescription.playlist.name
        guard
            let playlistTitlePlane = Plane(
                in: plane,
                state: .init(
                    absX: 4,
                    absY: 2,
                    width: UInt32(title.count),
                    height: 1
                ),
                debugID: "PDTP"
            )
        else {
            return nil
        }
        self.playlistTitlePlane = playlistTitlePlane

        let oneThirdWidth = Int32(state.width) / 3

        self.songsTitlePlane = Plane(
            in: plane,
            state: .init(
                absX: oneThirdWidth + 2,
                absY: 2,
                width: 6,
                height: 1
            ),
            debugID: "PDPALTP"
        )

        songItemPages = []

        loadSongs()

        loadArtwork()

        updateColors()

    }

    private func loadSongs() {
        let songs = playlistDescription.songs
        if !songs.isEmpty {
            self.songIndicesPlane = Plane(
                in: plane,
                state: .init(
                    absX: Int32(state.width) / 3 + 2,
                    absY: 4,
                    width: 2,
                    height: 5 * UInt32(min(maxItemsDisplayed + 1, songs.count))
                ),
                debugID: "PDPSIP"
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
                        type: .playlistDetailPage,
                        item: songs[songIndex]
                    )
                    self.songItemPages.append(songItem)
                }
            }
        }
    }

    private func loadArtwork() {
        Task {
            if let url = playlistDescription.playlist.artwork?.url(
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
                            "PlaylistDetailPage: Successfully obtained artwork RGBA byte array with count: \(pixelArray.count)"
                        )
                        Task { @MainActor in
                            self.handleArtwork(pixelArray: pixelArray)
                        }
                    } else {
                        await logger?.error("PlaylistDetailPage: Failed to get artwork RGBA byte array.")
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

        self.playlistTitlePlane?.erase()
        self.playlistTitlePlane?.destroy()

        self.songIndicesPlane?.erase()
        self.songIndicesPlane?.destroy()

        self.songsTitlePlane?.erase()
        self.songsTitlePlane?.destroy()

        for songPage in self.songItemPages {
            await songPage?.destroy()
        }
    }

    public func render() async {

    }

    public func updateColors() {
        let colorConfig = Theme.shared.playlistDetail

        self.plane.setColorPair(colorConfig.page)
        self.plane.blank()

        self.borderPlane.setColorPair(colorConfig.border)
        self.borderPlane.windowBorder(width: state.width, height: state.height)

        self.playlistTitlePlane?.setColorPair(colorConfig.playlistTitle)
        self.playlistTitlePlane?.putString(playlistDescription.playlist.name, at: (0, 0))

        self.songsTitlePlane?.setColorPair(colorConfig.songsText)
        self.songIndicesPlane?.setColorPair(colorConfig.songIndices)
        let songs = playlistDescription.songs
        if !songs.isEmpty {
            self.songsTitlePlane?.putString("Songs:", at: (0, 0))
            for songIndex in 0..<songs.count {
                if maxItemsDisplayed < songIndex {
                    break
                }
                self.songIndicesPlane?.putString("s\(songIndex)", at: (0, 2 + Int32(songIndex * 5)))
            }
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
