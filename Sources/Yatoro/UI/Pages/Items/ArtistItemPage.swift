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

    public enum ArtistItemPageType {
        case searchPage
        case songDetailPage
        case albumDetailPage
    }

    private let type: ArtistItemPageType

    public init?(
        in plane: Plane,
        state: PageState,
        item: Artist,
        type: ArtistItemPageType
    ) async {
        self.type = type
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
                debugID: "ARTIST_UI_\(item.id)_BORDER"
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
                    width: 6,
                    height: 1
                ),
                debugID: "ARTIST_UI_\(item.id)_PN"
            )
        else {
            return nil
        }
        self.pageNamePlane = pageNamePlane
        self.pageNamePlane.moveAbove(other: self.borderPlane)

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
        self.artistLeftPlane = artistLeftPlane
        self.artistLeftPlane.moveAbove(other: self.pageNamePlane)

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
        self.artistRightPlane = artistRightPlane
        self.artistRightPlane.moveAbove(other: self.artistLeftPlane)

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
        self.genreLeftPlane = genreLeftPlane
        self.genreLeftPlane.moveAbove(other: self.artistRightPlane)

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
            self.genreRightPlane = genreRightPlane
            self.genreRightPlane?.moveAbove(other: self.genreLeftPlane)
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
        self.albumsLeftPlane = albumsLeftPlane
        self.albumsLeftPlane.moveAbove(other: self.genreRightPlane ?? self.genreLeftPlane)

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
            self.albumsRightPlane = albumsRightPlane
            self.albumsRightPlane?.moveAbove(other: self.albumsLeftPlane)
        } else {
            self.albumsRightPlane = nil
        }

        self.item = item

        updateColors()
    }

    public func updateColors() {
        let colorConfig: Theme.ArtistItem
        switch type {
        case .searchPage:
            colorConfig = Theme.shared.search.artistItem
        case .songDetailPage:
            colorConfig = Theme.shared.songDetail.artistItem
        case .albumDetailPage:
            colorConfig = Theme.shared.albumDetail.artistItem
        }
        plane.setColorPair(colorConfig.page)
        borderPlane.setColorPair(colorConfig.border)
        pageNamePlane.setColorPair(colorConfig.pageName)
        artistLeftPlane.setColorPair(colorConfig.artistLeft)
        artistRightPlane.setColorPair(colorConfig.artistRight)
        genreLeftPlane.setColorPair(colorConfig.genreLeft)
        genreRightPlane?.setColorPair(colorConfig.genreRight)
        albumsLeftPlane.setColorPair(colorConfig.albumsLeft)
        albumsRightPlane?.setColorPair(colorConfig.albumsRight)

        plane.blank()
        borderPlane.windowBorder(width: state.width, height: state.height)
        pageNamePlane.putString("Artist", at: (0, 0))
        artistLeftPlane.putString("Artist:", at: (0, 0))
        artistRightPlane.putString(item.name, at: (0, 0))
        genreLeftPlane.putString("Genre:", at: (0, 0))
        if let genres = item.genres {
            var genreStr = ""
            for genre in genres {
                genreStr.append("\(genre.name), ")
            }
            if genreStr.count >= 2 {
                genreStr.removeLast(2)
            }
            genreRightPlane?.putString(genreStr, at: (0, 0))
        }
        albumsLeftPlane.putString("Albums:", at: (0, 0))
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
            albumsRightPlane?.putString(albumsStr, at: (0, 0))
        }
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
