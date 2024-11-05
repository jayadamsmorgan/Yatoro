import MusicKit
import SwiftNotCurses

@MainActor
public class ArtistItemPage: DestroyablePage {

    private var state: PageState
    private let plane: Plane

    private let borderPlane: Plane
    private let pageNamePlane: Plane
    private let artistLeftPlane: Plane
    private let artistRightPlane: Plane
    private let genreLeftPlane: Plane
    private let genreRightPlane: Plane?
    private let albumsLeftPlane: Plane
    private let albumsRightPlane: Plane?

    private let item: Artist

    public func getItem() async -> Artist { item }

    public init?(
        in plane: Plane,
        state: PageState,
        colorConfig: Config.UIConfig.Colors.ArtistItem,
        item: Artist
    ) async {
        self.state = state
        guard
            let pagePlane = Plane(
                in: plane,
                opts: .init(
                    pageState: state,
                    debugID: "ARTIST_UI_\(item.id)",
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
                debugID: "ARTIST_UI_\(item.id)_BORDER"
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
                    width: 6,
                    height: 1
                ),
                debugID: "ARTIST_UI_\(item.id)_PN"
            )
        else {
            return nil
        }
        pageNamePlane.backgroundColor = colorConfig.pageName.background
        pageNamePlane.foregroundColor = colorConfig.pageName.foreground
        pageNamePlane.putString("Artist", at: (0, 0))
        self.pageNamePlane = pageNamePlane

        var item = item
        do {
            item = try await item.with([.genres, .albums])
        } catch {
            logger?.error("ArtistItemPage: Unable to fetch genres and albums for \(item.id)")
        }

        guard
            let artistLeftPlane = Plane(
                in: pagePlane,
                state: .init(
                    absX: 2,
                    absY: 1,
                    width: 7,
                    height: 1
                ),
                debugID: "ARTIST_UI_\(item.id)_ARL"
            )
        else {
            return nil
        }
        artistLeftPlane.backgroundColor = colorConfig.artistLeft.background
        artistLeftPlane.foregroundColor = colorConfig.artistLeft.foreground
        artistLeftPlane.putString("Artist:", at: (0, 0))
        self.artistLeftPlane = artistLeftPlane

        let artistRightWidth = min(UInt32(item.name.count), state.width - 11)
        guard
            let artistRightPlane = Plane(
                in: pagePlane,
                state: .init(
                    absX: 10,
                    absY: 1,
                    width: artistRightWidth,
                    height: 1
                ),
                debugID: "ARTIST_UI_\(item.id)_ARR"
            )
        else {
            return nil
        }
        artistRightPlane.backgroundColor = colorConfig.artistRight.background
        artistRightPlane.foregroundColor = colorConfig.artistRight.foreground
        artistRightPlane.putString(item.name, at: (0, 0))
        self.artistRightPlane = artistRightPlane

        guard
            let genreLeftPlane = Plane(
                in: pagePlane,
                state: .init(
                    absX: 2,
                    absY: 2,
                    width: 6,
                    height: 1
                ),
                debugID: "ARTIST_UI_\(item.id)_GL"
            )
        else {
            return nil
        }
        genreLeftPlane.backgroundColor = colorConfig.genreLeft.background
        genreLeftPlane.foregroundColor = colorConfig.genreLeft.foreground
        genreLeftPlane.putString("Genre:", at: (0, 0))
        self.genreLeftPlane = genreLeftPlane

        if let genres = item.genres {
            var genreStr = ""
            for genre in genres {
                genreStr.append("\(genre.name), ")
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
                        absY: 2,
                        width: genreRightWidth,
                        height: 1
                    ),
                    debugID: "ARTIST_UI_\(item.id)_GR"
                )
            else {
                return nil
            }
            genreRightPlane.backgroundColor = colorConfig.genreRight.background
            genreRightPlane.foregroundColor = colorConfig.genreRight.foreground
            genreRightPlane.putString(genreStr, at: (0, 0))
            self.genreRightPlane = genreRightPlane
        } else {
            self.genreRightPlane = nil
        }

        guard
            let albumsLeftPlane = Plane(
                in: pagePlane,
                state: .init(
                    absX: 2,
                    absY: 3,
                    width: 7,
                    height: 1
                ),
                debugID: "ARTIST_UI_\(item.id)_ALL"
            )
        else {
            return nil
        }
        albumsLeftPlane.backgroundColor = colorConfig.albumsLeft.background
        albumsLeftPlane.foregroundColor = colorConfig.albumsLeft.foreground
        albumsLeftPlane.putString("Albums:", at: (0, 0))
        self.albumsLeftPlane = albumsLeftPlane

        if let albums = item.albums {
            var albumsStr = ""
            var albumIndex = 0
            for album in albums {
                if albumIndex > 2 {
                    break
                }
                albumsStr.append("\(album.title), ")
                albumIndex += 1
            }
            if albumsStr.count >= 2 {
                albumsStr.removeLast(2)
            }
            let albumsRightWidth = min(UInt32(albumsStr.count), state.width - 11)
            guard
                let albumsRightPlane = Plane(
                    in: pagePlane,
                    state: .init(
                        absX: 10,
                        absY: 3,
                        width: albumsRightWidth,
                        height: 1
                    ),
                    debugID: "ARTIST_UI_\(item.id)_ALR"
                )
            else {
                return nil
            }
            albumsRightPlane.backgroundColor = colorConfig.albumsRight.background
            albumsRightPlane.foregroundColor = colorConfig.albumsRight.foreground
            albumsRightPlane.putString(albumsStr, at: (0, 0))
            self.albumsRightPlane = albumsRightPlane
        } else {
            self.albumsRightPlane = nil
        }

        self.item = item

    }

    public func destroy() async {
        plane.erase()
        plane.destroy()

        borderPlane.erase()
        borderPlane.destroy()

        pageNamePlane.erase()
        pageNamePlane.destroy()

        artistLeftPlane.erase()
        artistLeftPlane.destroy()
        artistRightPlane.erase()
        artistRightPlane.destroy()

        genreLeftPlane.erase()
        genreLeftPlane.destroy()
        genreRightPlane?.erase()
        genreRightPlane?.destroy()

        albumsLeftPlane.erase()
        albumsLeftPlane.destroy()
        albumsRightPlane?.erase()
        albumsRightPlane?.destroy()
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
