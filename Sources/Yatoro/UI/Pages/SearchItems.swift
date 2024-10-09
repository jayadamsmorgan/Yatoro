import Logging
import MusicKit
import SwiftNotCurses

public class SongItemPage: Page {

    private var state: PageState
    private let plane: Plane

    private let item: Song

    public func getItem() async -> Song { item }

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
        plane.erase()
        plane.destroy()
    }

    public func render() async {
        plane.erase()

        plane.putString("type: song", at: (Int32(state.width) - 12, 0))
        plane.putString("title: \(item.title)", at: (2, 1))
        plane.putString("artist: \(item.artistName)", at: (2, 2))
        plane.putString(
            "duration: \(item.duration?.toMMSS() ?? "nil")",
            at: (2, 3)
        )
        plane.putString("album: \(item.albumTitle ?? "nil")", at: (2, 4))
        plane.putString(
            String(repeating: "─", count: Int(state.width - 4)),
            at: (2, 5)
        )
    }

    public func onResize(newPageState: PageState) async {
        self.state = newPageState
        plane.updateByPageState(state)
    }

    public func getPageState() async -> PageState { state }

    public func getMinDimensions() async -> (width: UInt32, height: UInt32) { (12, state.height) }

    public func getMaxDimensions() async -> (width: UInt32, height: UInt32)? { nil }

}
