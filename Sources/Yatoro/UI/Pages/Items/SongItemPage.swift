import MusicKit
import SwiftNotCurses

@MainActor
public class SongItemPage: DestroyablePage {

    private var state: PageState
    private let plane: Plane

    private let borderPlane: Plane
    private let pageNamePlane: Plane
    private let songLeftPlane: Plane
    private let songRightPlane: Plane
    private let albumLeftPlane: Plane
    private let albumRightPlane: Plane
    private let artistLeftPlane: Plane
    private let artistRightPlane: Plane

    private let item: Song

    public func getItem() async -> Song { item }

    public init?(
        in plane: Plane,
        state: PageState,
        colorConfig: Config.UIConfig.Colors.SongItem,
        item: Song
    ) {
        self.state = state
        guard
            let pagePlane = Plane(
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
        pagePlane.backgroundColor = colorConfig.page.background
        pagePlane.foregroundColor = colorConfig.page.foreground
        self.plane = pagePlane

        guard
            let borderPlane = Plane(
                in: pagePlane,
                state: .init(
                    absX: 0,
                    absY: 0,
                    width: state.width,
                    height: state.height
                ),
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
                in: pagePlane,
                state: .init(
                    absX: 3,
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

        guard
            let artistLeftPlane = Plane(
                in: pagePlane,
                state: .init(
                    absX: 2,
                    absY: 1,
                    width: 7,
                    height: 1
                ),
                debugID: "SONG_UI_\(item.id)_ARL"
            )
        else {
            return nil
        }
        artistLeftPlane.backgroundColor = colorConfig.artistLeft.background
        artistLeftPlane.foregroundColor = colorConfig.artistLeft.foreground
        artistLeftPlane.putString("Artist:", at: (0, 0))
        self.artistLeftPlane = artistLeftPlane

        let artistRightWidth = min(UInt32(item.artistName.count), state.width - 11)
        guard
            let artistRightPlane = Plane(
                in: pagePlane,
                state: .init(
                    absX: 10,
                    absY: 1,
                    width: artistRightWidth,
                    height: 1
                ),
                debugID: "SONG_UI_\(item.id)_ARR"
            )
        else {
            return nil
        }
        artistRightPlane.backgroundColor = colorConfig.artistRight.background
        artistRightPlane.foregroundColor = colorConfig.artistRight.foreground
        artistRightPlane.putString(item.artistName, at: (0, 0))
        self.artistRightPlane = artistRightPlane

        guard
            let songLeftPlane = Plane(
                in: pagePlane,
                state: .init(
                    absX: 2,
                    absY: 2,
                    width: 5,
                    height: 1
                ),
                debugID: "SONG_UI_\(item.id)_SL"
            )
        else {
            return nil
        }
        songLeftPlane.backgroundColor = colorConfig.songLeft.background
        songLeftPlane.foregroundColor = colorConfig.songLeft.foreground
        songLeftPlane.putString("Song:", at: (0, 0))
        self.songLeftPlane = songLeftPlane

        let songRightWidth = min(UInt32(item.title.count), state.width - 9)
        guard
            let songRightPlane = Plane(
                in: pagePlane,
                state: .init(
                    absX: 8,
                    absY: 2,
                    width: songRightWidth,
                    height: 1
                ),
                debugID: "SONG_UI_\(item.id)_SR"
            )
        else {
            return nil
        }
        songRightPlane.backgroundColor = colorConfig.songRight.background
        songRightPlane.foregroundColor = colorConfig.songRight.foreground
        songRightPlane.putString(item.title, at: (0, 0))
        self.songRightPlane = songRightPlane

        guard
            let albumLeftPlane = Plane(
                in: pagePlane,
                state: .init(
                    absX: 2,
                    absY: 3,
                    width: 6,
                    height: 1
                ),
                debugID: "SONG_UI_\(item.id)_AL"
            )
        else {
            return nil
        }
        albumLeftPlane.backgroundColor = colorConfig.albumLeft.background
        albumLeftPlane.foregroundColor = colorConfig.albumLeft.foreground
        albumLeftPlane.putString("Album:", at: (0, 0))
        self.albumLeftPlane = albumLeftPlane

        let albumRightWidth = min(UInt32(item.albumTitle?.count ?? 1), state.width - 10)
        guard
            let albumRightPlane = Plane(
                in: pagePlane,
                state: .init(
                    absX: 9,
                    absY: 3,
                    width: albumRightWidth,
                    height: 1
                ),
                debugID: "SONG_UI_\(item.id)_AR"
            )
        else {
            return nil
        }
        albumRightPlane.backgroundColor = colorConfig.albumRight.background
        albumRightPlane.foregroundColor = colorConfig.albumRight.foreground
        albumRightPlane.putString(item.albumTitle ?? " ", at: (0, 0))
        self.albumRightPlane = albumRightPlane

        self.item = item
    }

    public func destroy() async {
        plane.erase()
        plane.destroy()

        borderPlane.erase()
        borderPlane.destroy()

        pageNamePlane.erase()
        pageNamePlane.destroy()

        albumLeftPlane.erase()
        albumLeftPlane.destroy()
        albumRightPlane.erase()
        albumRightPlane.destroy()

        songLeftPlane.erase()
        songLeftPlane.destroy()
        songRightPlane.erase()
        songRightPlane.destroy()

        artistLeftPlane.erase()
        artistLeftPlane.destroy()
        artistRightPlane.erase()
        artistRightPlane.destroy()
    }

    public func render() async {

    }

    public func onResize(newPageState: PageState) async {
        self.state = newPageState
        plane.updateByPageState(state)
        plane.blank()

        borderPlane.updateByPageState(state)
        borderPlane.erase()
        borderPlane.windowBorder(width: state.width, height: state.height)
    }

    public func getPageState() async -> PageState { state }

    public func getMinDimensions() async -> (width: UInt32, height: UInt32) { (12, state.height) }

    public func getMaxDimensions() async -> (width: UInt32, height: UInt32)? { nil }

}
