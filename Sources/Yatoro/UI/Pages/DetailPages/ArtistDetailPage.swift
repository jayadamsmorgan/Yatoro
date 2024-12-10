import SwiftNotCurses

public class ArtistDetailPage: DestroyablePage {

    private var state: PageState

    private var plane: Plane

    private var borderPlane: Plane
    private var artworkPlane: Plane?

    private var artistTitlePlane: Plane  // Name of the song
    // private var topSongsTitlePlane: Plane  // "Top Songs:"
    // private var albumsTitlePlane: Plane  // Name of the album

    public func destroy() async {

    }

    public init?(
        in plane: Plane,
        state: PageState,
        artistDescription: ArtistDescriptionResult
    ) {
        self.state = state

        guard
            let plane = Plane(
                in: plane,
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

        let title = artistDescription.artist.name
        guard
            let artistTitlePlane = Plane(
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
        artistTitlePlane.putString(title, at: (0, 0))
        self.artistTitlePlane = artistTitlePlane
    }

    public func render() async {

    }

    public func updateColors() {

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
