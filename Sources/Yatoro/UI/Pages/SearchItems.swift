import Logging
import MusicKit
import notcurses

public class SongSearchItemPage: Page {

    private var state: PageState
    private let plane: Plane

    private let item: Song
    private let logger: Logger?

    public func getItem() async -> Song {
        item
    }

    public init?(in plane: Plane, position: Int, item: Song, logger: Logger?) {
        let songHeight: Int32 = 6
        self.state = .init(
            absX: 0,
            absY: 2 + Int32(position) * songHeight,
            width: plane.width,
            height: UInt32(songHeight)
        )
        guard
            let plane = Plane(
                in: plane,
                opts: .init(
                    pageState: state,
                    debugID: "SONG_UI_\(item.id)",
                    flags: []
                ),
                logger: logger
            )
        else {
            return nil
        }
        self.plane = plane
        self.logger = logger
        self.item = item
    }

    public func destroy() async {
        ncplane_erase(plane.ncplane)
        ncplane_destroy(plane.ncplane)
    }

    public func render() async {
        let output = Output(plane: plane)
        output.putString("type: song", at: (Int32(state.width) - 10, 0))
        output.putString("title: \(item.title)", at: (0, 1))
        output.putString("artist: \(item.artistName)", at: (0, 2))
        output.putString(
            "duration: \(item.duration?.toMMSS() ?? "nil")",
            at: (0, 3)
        )
        output.putString("album: \(item.albumTitle ?? "nil")", at: (0, 4))
        output.putString(
            String(repeating: "─", count: Int(state.width)),
            at: (0, 5)
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
