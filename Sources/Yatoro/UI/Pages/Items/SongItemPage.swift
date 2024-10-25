import MusicKit
import SwiftNotCurses

@MainActor
public class SongItemPage: Page {

    private var state: PageState
    private let plane: Plane

    private let borderPlane: Plane
    private let pageNamePlane: Plane

    private let item: Song

    public func getItem() async -> Song { item }

    public init?(
        in plane: Plane,
        state: PageState,
        colorConfig: Config.UIConfig.Colors.Item,
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
        plane.backgroundColor = colorConfig.page.background
        plane.foregroundColor = colorConfig.page.foreground

        guard
            let borderPlane = Plane(
                in: plane,
                state: state,
                debugID: "SONG_UI_\(item.id)_BORDER"
            )
        else {
            return nil
        }
        borderPlane.backgroundColor = colorConfig.border.background
        borderPlane.foregroundColor = colorConfig.border.foreground
        borderPlane.windowBorder(width: state.width, height: state.height)
        self.borderPlane = borderPlane

        guard
            let pageNamePlane = Plane(
                in: plane,
                state: .init(
                    absX: 2,
                    absY: 0,
                    width: 4,
                    height: 1
                ),
                debugID: "SONG_UI_\(item.id)_PN"
            )
        else {
            return nil
        }
        pageNamePlane.backgroundColor = colorConfig.pageName.background
        pageNamePlane.foregroundColor = colorConfig.pageName.foreground
        pageNamePlane.putString("Song", at: (0, 0))
        self.pageNamePlane = pageNamePlane

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
