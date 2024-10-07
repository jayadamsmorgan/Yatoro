import Logging
import MusicKit
import notcurses

public class SongItemPage: Page {

    private var state: PageState
    private let plane: Plane

    private let item: Song

    public func getItem() async -> Song {
        item
    }

    public init?(
        in plane: Plane,
        state: PageState,
        item: Song
    ) {
        self.state = state
        guard
            let plane = Plane(
                in: plane,
                opts: .init(
                    pageState: state,
                    debugID: "SONG_UI_\(item.id)",
                    flags: []
                )
            )
        else {
            return nil
        }
        self.plane = plane
        self.item = item
    }

    public func destroy() async {
        ncplane_erase(plane.ncplane)
        ncplane_destroy(plane.ncplane)
    }

    public func render() async {
        ncplane_erase(plane.ncplane)
        let output = Output(plane: plane)
        output.putString("type: song", at: (Int32(state.width) - 12, 0))
        output.putString("title: \(item.title)", at: (2, 1))
        output.putString("artist: \(item.artistName)", at: (2, 2))
        output.putString(
            "duration: \(item.duration?.toMMSS() ?? "nil")",
            at: (2, 3)
        )
        output.putString("album: \(item.albumTitle ?? "nil")", at: (2, 4))
        output.putString(
            String(repeating: "─", count: Int(state.width - 4)),
            at: (2, 5)
        )
    }

    public func onResize(newPageState: PageState) async {
        self.state = newPageState
        ncplane_resize_simple(plane.ncplane, state.height, state.width)
        ncplane_move_yx(plane.ncplane, state.absY, state.absX)
    }

    public func getPageState() async -> PageState {
        state
    }

    public func getMinDimensions() async -> (width: UInt32, height: UInt32) {
        (12, state.height)
    }

    public func getMaxDimensions() async -> (width: UInt32, height: UInt32)? {
        nil
    }

}
