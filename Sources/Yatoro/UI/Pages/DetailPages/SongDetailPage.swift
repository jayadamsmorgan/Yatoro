import SwiftNotCurses

@MainActor
public class SongDetailPage: Page {

    private var state: PageState

    private var plane: Plane

    private var borderPlane: Plane

    private var artworkPlane: Plane
    private var artworkVisual: Visual?

    private var songTitlePlane: Plane  // Name of the song
    private var artistsTitlePlane: Plane  // "Artists:"
    // private var artistsPlane: Plane  // list of artists themselves
    // private var albumPlane: Plane  // Name of the album

    // TODO: Maybe consider displaying lyrics if they're present, idk

    public init?(
        in stdPlane: Plane,
        state: PageState,
        songDescription: SongDescriptionResult
    ) {
        self.state = state

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
        plane.moveOnTopOfZStack()
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
                    absX: 2,
                    absY: 0,
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

        guard
            let artistsTitlePlane = Plane(
                in: plane,
                state: .init(
                    absX: 30,
                    absY: 2,
                    width: 8,
                    height: 1
                ),
                debugID: "SDPATP"
            )
        else {
            return nil
        }
        self.artistsTitlePlane = artistsTitlePlane

        Task {
            do {
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
            } catch {

            }
        }

    }

    public func render() async {

    }

    public func updateColors() {

    }

    func handleArtwork(pixelArray: [UInt8]) {
        let artworkPlaneWidth = min(self.state.width / 2, self.state.height - 3)
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
                absX: Int32(self.state.width / 2 - artworkPlaneWidth / 2),
                absY: Int32(self.state.height / 2 - artworkPlaneHeight / 2),
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

    public func onResize(newPageState: PageState) async {
        self.state = newPageState

        borderPlane.updateByPageState(.init(absX: 0, absY: 0, width: state.width, height: state.height))
        borderPlane.erase()
        borderPlane.windowBorder(width: state.width, height: state.height)

    }

    public func getPageState() async -> PageState { state }

    public func getMinDimensions() async -> (width: UInt32, height: UInt32) { (23, 23) }

    public func getMaxDimensions() async -> (width: UInt32, height: UInt32)? { nil }

}
