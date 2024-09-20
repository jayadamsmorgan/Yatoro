import Logging
import MusadoraKit
import notcurses

public struct SearchPage: Page {

    public var plane: Plane
    public var logger: Logger?

    private let output: Output

    public var width: UInt32 = 28
    public var height: UInt32 = 13

    public var lastSearch: MusicCatalogSearchResponse?
    public var currentSearchFilter: MCatalogSearchType = .songs

    public init?(stdPlane: Plane, logger: Logger?) {
        guard
            let plane = Plane(
                in: stdPlane,
                opts: .init(
                    x: 30,
                    y: 0,
                    width: width,
                    height: height,
                    debugID: "SEARCH_PAGE"
                        // flags: [.verticalScrolling]
                ),
                logger: logger
            )
        else {
            return nil
        }
        self.plane = plane
        self.logger = logger
        self.output = .init(plane: plane)
    }

    public func onResize() {
    }

    public func render() {
        output.putString("Search \(currentSearchFilter):", at: (0, 0))
        guard let lastSearch else {
            return
        }
        switch currentSearchFilter {

        case .songs:
            renderSongs(items: Array(lastSearch.songs))
        case .albums:
            renderAlbums(items: Array(lastSearch.albums))
        case .playlists:
            renderPlaylists(items: Array(lastSearch.playlists))
        case .artists:
            renderArtists(items: Array(lastSearch.artists))
        case .stations:
            renderStations(items: Array(lastSearch.stations))
        case .radioShows:
            renderRadioShows(items: Array(lastSearch.radioShows))
        default:
            return
        }
    }

    private func renderSongs(items: [Song]) {

    }

    private func renderAlbums(items: [Album]) {

    }

    private func renderStations(items: [Station]) {

    }

    private func renderPlaylists(items: [Playlist]) {

    }

    private func renderArtists(items: [Artist]) {

    }

    private func renderRadioShows(items: [RadioShow]) {

    }

}
