import MusicKit
import SwiftNotCurses

@MainActor
public class AlbumItemPage: DestroyablePage {

    private var state: PageState
    private let plane: Plane

    private let borderPlane: Plane
    private let pageNamePlane: Plane
    private let genreLeftPlane: Plane
    private let genreRightPlane: Plane
    private let albumLeftPlane: Plane
    private let albumRightPlane: Plane
    private let artistLeftPlane: Plane
    private let artistRightPlane: Plane

    private let item: Album

    public enum AlbumItemPageType {
        case searchPage
        case songDetailPage
        case artistDetailPage
        case recommendationDetailPage
    }

    private let type: AlbumItemPageType

    public func getItem() async -> Album { item }

    public init?(
        in plane: Plane,
        state: PageState,
        item: Album,
        type: AlbumItemPageType
    ) {
        self.type = type
        self.state = state
        guard
            let pagePlane = Plane(
                in: plane,
                opts: .init(
                    pageState: state,
                    debugID: "ALBUM_UI_\(item.id)",
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
                debugID: "ALBUM_UI_\(item.id)_BORDER"
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
                    width: 5,
                    height: 1
                ),
                debugID: "ALBUM_UI_\(item.id)_PN"
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
                debugID: "ALBUM_UI_\(item.id)_ARL"
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
                debugID: "ALBUM_UI_\(item.id)_ARR"
            )
        else {
            return nil
        }
        self.artistRightPlane = artistRightPlane
        self.artistLeftPlane.moveAbove(other: self.artistLeftPlane)

        guard
            let genreLeftPlane = Plane(
                in: pagePlane,
                state: .init(
                    absX: 2,
                    absY: 3,
                    width: 6,
                    height: 1
                ),
                debugID: "ALBUM_UI_\(item.id)_GL"
            )
        else {
            return nil
        }
        self.genreLeftPlane = genreLeftPlane
        self.genreLeftPlane.moveAbove(other: self.artistRightPlane)

        var genreStr = ""
        for genre in item.genreNames {
            if genre == "Music" {
                continue
            }
            genreStr.append("\(genre), ")
        }
        if genreStr.count >= 2 {
            genreStr.removeLast(2)
        }
        let genreRightWidth = min(UInt32(genreStr.count), state.width - 10)
        guard
            let genreRightPlane = Plane(
                in: pagePlane,
                state: .init(
                    absX: 9,
                    absY: 3,
                    width: genreRightWidth,
                    height: 1
                ),
                debugID: "ALBUM_UI_\(item.id)_GR"
            )
        else {
            return nil
        }
        self.genreRightPlane = genreRightPlane
        self.genreRightPlane.moveAbove(other: self.genreLeftPlane)

        guard
            let albumLeftPlane = Plane(
                in: pagePlane,
                state: .init(
                    absX: 2,
                    absY: 2,
                    width: 6,
                    height: 1
                ),
                debugID: "ALBUM_UI_\(item.id)_AL"
            )
        else {
            return nil
        }
        self.albumLeftPlane = albumLeftPlane
        self.albumLeftPlane.moveAbove(other: self.genreRightPlane)

        let albumRightWidth = min(UInt32(item.title.count), state.width - 10)
        guard
            let albumRightPlane = Plane(
                in: pagePlane,
                state: .init(
                    absX: 9,
                    absY: 2,
                    width: albumRightWidth,
                    height: 1
                ),
                debugID: "ALBUM_UI_\(item.id)_AR"
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
        let colorConfig: Config.UIConfig.Colors.AlbumItem
        switch self.type {
        case .searchPage:
            colorConfig = Config.shared.ui.colors.search.albumItem
        case .songDetailPage:
            colorConfig = Config.shared.ui.colors.songDetail.albumItem
        case .artistDetailPage:
            colorConfig = Config.shared.ui.colors.artistDetail.albumItem
        case .recommendationDetailPage:
            colorConfig = Config.shared.ui.colors.recommendationDetail.albumItem
        }
        plane.setColorPair(colorConfig.page)
        borderPlane.setColorPair(colorConfig.border)
        pageNamePlane.setColorPair(colorConfig.pageName)
        artistLeftPlane.setColorPair(colorConfig.artistLeft)
        artistRightPlane.setColorPair(colorConfig.artistRight)
        genreLeftPlane.setColorPair(colorConfig.genreLeft)
        genreRightPlane.setColorPair(colorConfig.genreRight)
        albumLeftPlane.setColorPair(colorConfig.albumLeft)
        albumRightPlane.setColorPair(colorConfig.albumRight)

        plane.blank()
        borderPlane.windowBorder(width: state.width, height: state.height)
        pageNamePlane.putString("Album", at: (0, 0))
        artistLeftPlane.putString("Artist:", at: (0, 0))
        artistRightPlane.putString(item.artistName, at: (0, 0))
        genreLeftPlane.putString("Genre:", at: (0, 0))
        var genreStr = ""
        for genre in item.genreNames {
            if genre == "Music" {
                continue
            }
            genreStr.append("\(genre), ")
        }
        if genreStr.count >= 2 {
            genreStr.removeLast(2)
        }
        genreRightPlane.putString(genreStr, at: (0, 0))
        albumLeftPlane.putString("Album:", at: (0, 0))
        albumRightPlane.putString(item.title, at: (0, 0))
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

        genreLeftPlane.erase()
        genreLeftPlane.destroy()
        genreRightPlane.erase()
        genreRightPlane.destroy()

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
