import MusicKit

public actor RecommendedPage: Page {

    typealias Recommendations = MusicItemCollection<MusicPersonalRecommendation>

    private var state: PageState
    private let plane: Plane

    private var cache: Recommendations

    public init?(in stdPlane: Plane, state: PageState) {
        self.state = state
        guard let plane = Plane(in: stdPlane, opts: .init(pageState: state))
        else {
            return nil
        }
        self.plane = plane
        self.cache = []
    }

    public func render() async {

    }

    public func onResize(newPageState: PageState) async {
        self.state = newPageState
        plane.updateByPageState(state)
    }

    public func getPageState() async -> PageState { self.state }

    public func getMinDimensions() async -> (width: UInt32, height: UInt32) { (23, 17) }

    public func getMaxDimensions() async -> (width: UInt32, height: UInt32)? { nil }

}
