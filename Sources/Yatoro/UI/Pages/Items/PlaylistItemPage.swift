import MusicKit
import SwiftNotCurses

@MainActor
public class PlaylistItemPage: DestroyablePage {

    private var state: PageState
    private let plane: Plane

    private let borderPlane: Plane
    private let pageNamePlane: Plane
    private let descriptionLeftPlane: Plane
    private let descriptionRightPlane: Plane
    private let curatorLeftPlane: Plane
    private let curatorRightPlane: Plane
    private let playlistLeftPlane: Plane
    private let playlistRightPlane: Plane

    private let item: Playlist

    public func getItem() async -> Playlist { item }

    public init?(
        in plane: Plane,
        state: PageState,
        colorConfig: Config.UIConfig.Colors.PlaylistItem,
        item: Playlist
    ) {
        self.state = state
        guard
            let pagePlane = Plane(
                in: plane,
                opts: .init(
                    pageState: state,
                    debugID: "PLAYLIST_UI_\(item.id)",
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
                debugID: "PLAYLIST_UI_\(item.id)_BORDER"
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
                    width: 8,
                    height: 1
                ),
                debugID: "PLAYLIST_UI_\(item.id)_PN"
            )
        else {
            return nil
        }
        pageNamePlane.backgroundColor = colorConfig.pageName.background
        pageNamePlane.foregroundColor = colorConfig.pageName.foreground
        pageNamePlane.putString("Playlist", at: (0, 0))
        self.pageNamePlane = pageNamePlane

        guard
            let playlistLeftPlane = Plane(
                in: pagePlane,
                state: .init(
                    absX: 2,
                    absY: 1,
                    width: 9,
                    height: 1
                ),
                debugID: "PLAYLIST_UI_\(item.id)_PL"
            )
        else {
            return nil
        }
        playlistLeftPlane.backgroundColor = colorConfig.playlistLeft.background
        playlistLeftPlane.foregroundColor = colorConfig.playlistLeft.foreground
        playlistLeftPlane.putString("Playlist:", at: (0, 0))
        self.playlistLeftPlane = playlistLeftPlane

        let playlistRightWidth = min(UInt32(item.name.count), state.width - 13)
        guard
            let playlistRightPlane = Plane(
                in: pagePlane,
                state: .init(
                    absX: 12,
                    absY: 1,
                    width: playlistRightWidth,
                    height: 1
                ),
                debugID: "PLAYLIST_UI_\(item.id)_PR"
            )
        else {
            return nil
        }
        playlistRightPlane.backgroundColor = colorConfig.playlistRight.background
        playlistRightPlane.foregroundColor = colorConfig.playlistRight.foreground
        playlistRightPlane.putString(item.name, at: (0, 0))
        self.playlistRightPlane = playlistRightPlane

        guard
            let descriptionLeftPlane = Plane(
                in: pagePlane,
                state: .init(
                    absX: 2,
                    absY: 3,
                    width: 12,
                    height: 1
                ),
                debugID: "PLAYLIST_UI_\(item.id)_DL"
            )
        else {
            return nil
        }
        descriptionLeftPlane.backgroundColor = colorConfig.descriptionLeft.background
        descriptionLeftPlane.foregroundColor = colorConfig.descriptionLeft.foreground
        descriptionLeftPlane.putString("Description:", at: (0, 0))
        self.descriptionLeftPlane = descriptionLeftPlane

        var descriptionRightWidth = min(UInt32(item.standardDescription?.count ?? 1), state.width - 16)
        if descriptionRightWidth == 0 { descriptionRightWidth = 1 }
        guard
            let descriptionRightPlane = Plane(
                in: pagePlane,
                state: .init(
                    absX: 15,
                    absY: 3,
                    width: descriptionRightWidth,
                    height: 1
                ),
                debugID: "PLAYLIST_UI_\(item.id)_DR"
            )
        else {
            return nil
        }
        descriptionRightPlane.backgroundColor = colorConfig.descriptionRight.background
        descriptionRightPlane.foregroundColor = colorConfig.descriptionRight.foreground
        descriptionRightPlane.putString(item.standardDescription ?? "", at: (0, 0))
        self.descriptionRightPlane = descriptionRightPlane

        guard
            let curatorLeftPlane = Plane(
                in: pagePlane,
                state: .init(
                    absX: 2,
                    absY: 2,
                    width: 8,
                    height: 1
                ),
                debugID: "PLAYLIST_UI_\(item.id)_CL"
            )
        else {
            return nil
        }
        curatorLeftPlane.backgroundColor = colorConfig.curatorLeft.background
        curatorLeftPlane.foregroundColor = colorConfig.curatorLeft.foreground
        curatorLeftPlane.putString("Curator:", at: (0, 0))
        self.curatorLeftPlane = curatorLeftPlane

        let curatorRightWidth = min(UInt32(item.curatorName?.count ?? 1), state.width - 12)
        guard
            let curatorRightPlane = Plane(
                in: pagePlane,
                state: .init(
                    absX: 11,
                    absY: 2,
                    width: curatorRightWidth,
                    height: 1
                ),
                debugID: "PLAYLIST_UI_\(item.id)_CR"
            )
        else {
            return nil
        }
        curatorRightPlane.backgroundColor = colorConfig.curatorRight.background
        curatorRightPlane.foregroundColor = colorConfig.curatorRight.foreground
        curatorRightPlane.putString(item.curatorName ?? "", at: (0, 0))
        self.curatorRightPlane = curatorRightPlane

        self.item = item
    }

    public func destroy() async {
        plane.erase()
        plane.destroy()

        borderPlane.erase()
        borderPlane.destroy()

        pageNamePlane.erase()
        pageNamePlane.destroy()

        curatorLeftPlane.erase()
        curatorLeftPlane.destroy()
        curatorRightPlane.erase()
        curatorRightPlane.destroy()

        descriptionLeftPlane.erase()
        descriptionLeftPlane.destroy()
        descriptionRightPlane.erase()
        descriptionRightPlane.destroy()

        playlistLeftPlane.erase()
        playlistLeftPlane.destroy()
        playlistRightPlane.erase()
        playlistRightPlane.destroy()
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
