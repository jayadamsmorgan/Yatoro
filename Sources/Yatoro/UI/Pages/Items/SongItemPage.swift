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

    public enum SongItemPageType {
        case searchPage
        case queuePage
        case artistDetailPage
        case albumDetailPage
        case playlistDetailPage
    }

    private let type: SongItemPageType

    public init?(
        in plane: Plane,
        state: PageState,
        type: SongItemPageType,
        item: Song
    ) {
        self.type = type
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
        self.plane = pagePlane
        self.plane.moveAbove(other: plane)

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
        self.borderPlane = borderPlane
        self.borderPlane.moveAbove(other: self.plane)

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
        self.pageNamePlane = pageNamePlane
        self.pageNamePlane.moveAbove(other: self.borderPlane)

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
        self.artistLeftPlane = artistLeftPlane
        self.artistLeftPlane.moveAbove(other: self.pageNamePlane)

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
        self.artistRightPlane = artistRightPlane
        self.artistRightPlane.moveAbove(other: self.artistLeftPlane)

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
        self.songLeftPlane = songLeftPlane
        self.songLeftPlane.moveAbove(other: self.artistRightPlane)

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
        self.songRightPlane = songRightPlane
        self.songRightPlane.moveAbove(other: self.songLeftPlane)

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
        self.albumLeftPlane = albumLeftPlane
        self.albumLeftPlane.moveAbove(other: self.songRightPlane)

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
        self.albumRightPlane = albumRightPlane
        self.albumRightPlane.moveAbove(other: self.albumLeftPlane)

        self.item = item

        updateColors()
    }

    public func updateColors() {
        let colorConfig: Config.UIConfig.Colors.SongItem
        switch type {
        case .queuePage: colorConfig = Config.shared.ui.colors.queue.songItem
        case .searchPage: colorConfig = Config.shared.ui.colors.search.songItem
        case .artistDetailPage: colorConfig = Config.shared.ui.colors.artistDetail.songItem
        case .albumDetailPage: colorConfig = Config.shared.ui.colors.albumDetail.songItem
        case .playlistDetailPage: colorConfig = Config.shared.ui.colors.playlistDetail.songItem
        }
        plane.setColorPair(colorConfig.page)
        borderPlane.setColorPair(colorConfig.border)
        pageNamePlane.setColorPair(colorConfig.pageName)
        artistLeftPlane.setColorPair(colorConfig.artistLeft)
        artistRightPlane.setColorPair(colorConfig.artistRight)
        songLeftPlane.setColorPair(colorConfig.songLeft)
        songRightPlane.setColorPair(colorConfig.songRight)
        albumLeftPlane.setColorPair(colorConfig.albumLeft)
        albumRightPlane.setColorPair(colorConfig.albumRight)

        plane.blank()
        borderPlane.windowBorder(width: state.width, height: state.height)
        pageNamePlane.putString("Song", at: (0, 0))
        artistLeftPlane.putString("Artist:", at: (0, 0))
        artistRightPlane.putString(item.artistName, at: (0, 0))
        songLeftPlane.putString("Song:", at: (0, 0))
        songRightPlane.putString(item.title, at: (0, 0))
        albumLeftPlane.putString("Album:", at: (0, 0))
        albumRightPlane.putString(item.albumTitle ?? " ", at: (0, 0))
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
