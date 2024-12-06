import SwiftNotCurses

public class SongDetailPage: Page {

    private var state: PageState

    private var plane: Plane

    private var borderPlane: Plane
    private var artworkPlane: Plane?

    private var songTitlePlane: Plane  // Name of the song
    // private var artistsTitlePlane: Plane  // "Artists:"
    // private var artistsPlane: Plane  // list of artists themselves
    // private var albumPlane: Plane  // Name of the album

    // TODO: Maybe consider displaying lyrics if they're present, idk

    public init?(
        in plane: Plane,
        state: PageState,
        songDescription: SongDescriptionResult
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
