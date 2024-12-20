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

    public enum PlaylistItemPageType {
        case searchPage
        case recommendationDetail
    }

    private let type: PlaylistItemPageType

    public init?(
        in plane: Plane,
        state: PageState,
        item: Playlist,
        type: PlaylistItemPageType
    ) {
        self.type = type
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
                debugID: "PLAYLIST_UI_\(item.id)_BORDER"
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
                    width: 8,
                    height: 1
                ),
                debugID: "PLAYLIST_UI_\(item.id)_PN"
            )
        else {
            return nil
        }
        self.pageNamePlane = pageNamePlane
        self.pageNamePlane.moveAbove(other: self.borderPlane)

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
        self.playlistLeftPlane = playlistLeftPlane
        self.playlistLeftPlane.moveAbove(other: self.pageNamePlane)

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
        self.playlistRightPlane = playlistRightPlane
        self.playlistRightPlane.moveAbove(other: self.playlistLeftPlane)

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
        self.descriptionLeftPlane = descriptionLeftPlane
        self.descriptionLeftPlane.moveAbove(other: self.playlistRightPlane)

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
        self.descriptionRightPlane = descriptionRightPlane
        self.descriptionRightPlane.moveAbove(other: self.descriptionLeftPlane)

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
        self.curatorLeftPlane = curatorLeftPlane
        self.curatorLeftPlane.moveAbove(other: self.descriptionRightPlane)

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
        self.curatorRightPlane = curatorRightPlane
        self.curatorRightPlane.moveAbove(other: self.curatorLeftPlane)

        self.item = item

        updateColors()
    }

    public func updateColors() {
        let colorConfig: Theme.PlaylistItem
        switch self.type {
        case .searchPage:
            colorConfig = Config.shared.ui.theme.search.playlistItem
        case .recommendationDetail:
            colorConfig = Config.shared.ui.theme.recommendationDetail.playlistItem
        }
        plane.setColorPair(colorConfig.page)
        borderPlane.setColorPair(colorConfig.border)
        pageNamePlane.setColorPair(colorConfig.pageName)
        playlistLeftPlane.setColorPair(colorConfig.playlistLeft)
        playlistRightPlane.setColorPair(colorConfig.playlistRight)
        descriptionLeftPlane.setColorPair(colorConfig.descriptionLeft)
        descriptionRightPlane.setColorPair(colorConfig.descriptionRight)
        curatorLeftPlane.setColorPair(colorConfig.curatorLeft)
        curatorRightPlane.setColorPair(colorConfig.curatorRight)

        plane.blank()
        borderPlane.windowBorder(width: state.width, height: state.height)
        pageNamePlane.putString("Playlist", at: (0, 0))
        playlistLeftPlane.putString("Playlist:", at: (0, 0))
        playlistRightPlane.putString(item.name, at: (0, 0))
        descriptionLeftPlane.putString("Description:", at: (0, 0))
        descriptionRightPlane.putString(item.standardDescription ?? "", at: (0, 0))
        curatorLeftPlane.putString("Curator:", at: (0, 0))
        curatorRightPlane.putString(item.curatorName ?? "", at: (0, 0))
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
