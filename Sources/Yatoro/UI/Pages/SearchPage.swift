import Logging
import MusadoraKit
import notcurses

public actor SearchPage: Page {

    private let plane: Plane
    private let logger: Logger?

    private let output: Output

    private var state: PageState

    public var currentSearchFilter: MCatalogSearchType = .songs

    public func onResize(newPageState: PageState) async {
        self.state = newPageState
        ncplane_move_yx(plane.ncplane, state.absY, state.absX)
        ncplane_resize_simple(plane.ncplane, state.height, state.width)
    }

    public func getPageState() async -> PageState {
        self.state
    }

    public func getMaxDimensions() async -> (width: UInt32, height: UInt32)? {
        nil
    }

    public func getMinDimensions() async -> (width: UInt32, height: UInt32) {
        (23, 17)
    }

    public init?(stdPlane: Plane, state: PageState, logger: Logger?) {
        self.state = state
        guard
            let plane = Plane(
                in: stdPlane,
                opts: .init(
                    x: 30,
                    y: 0,
                    width: state.width,
                    height: state.height,
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

    public func render() async {
        output.putString("Search \(currentSearchFilter):", at: (0, 0))
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
