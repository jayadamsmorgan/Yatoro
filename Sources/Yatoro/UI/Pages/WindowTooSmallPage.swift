import Logging
import notcurses

public actor WindowTooSmallPage: Page {

    private let plane: Plane

    private let output: Output

    private var state: PageState

    private let logger: Logger?

    private var minRequiredDim: (minWidth: UInt32, minHeight: UInt32) = (0, 0)

    public func setMinRequiredDim(
        _ minRequiredDim: (minWidth: UInt32, minHeight: UInt32)
    ) async {
        self.minRequiredDim = minRequiredDim
    }

    public func getPageState() async -> PageState {
        self.state
    }

    public func getMinDimensions() async -> (width: UInt32, height: UInt32) {
        (0, 0)
    }

    public func getMaxDimensions() async -> (width: UInt32, height: UInt32)? {
        nil
    }

    public init?(stdPlane: Plane, logger: Logger?) {
        self.logger = logger
        guard
            let plane = Plane(
                in: stdPlane,
                opts: .init(
                    x: 0,
                    y: 0,
                    width: stdPlane.width,
                    height: stdPlane.height,
                    debugID: "WINDOW_TOO_SMALL_PAGE",
                    flags: []
                ),
                logger: logger
            )
        else {
            return nil
        }
        self.plane = plane
        self.state = .init(
            absX: 0,
            absY: 0,
            width: stdPlane.width,
            height: stdPlane.height
        )
        self.output = .init(plane: plane)
    }

    public func windowTooSmall() -> Bool {
        return self.state.height - 2 < minRequiredDim.minHeight
            || self.state.width < minRequiredDim.minWidth
    }

    public func render() async {
        ncplane_erase(plane.ncplane)

        guard windowTooSmall() else {
            ncplane_move_bottom(plane.ncplane)
            return
        }
        ncplane_move_top(plane.ncplane)

        for i in 0..<self.state.height {
            output.putString(
                String(repeating: " ", count: Int(self.state.width)),
                at: (0, Int32(i))
            )
        }
        let output = Output(plane: plane)
        let halfWidth = Int32(state.width) / 2
        let halfHeight = Int32(state.height) / 2
        output.putString(
            "Terminal size too small:",
            at: (halfWidth - 12, halfHeight - 2)
        )
        output.putString(
            "Width: \(state.width), Height: \(state.height)",
            at: (halfWidth - 12, halfHeight - 1)
        )
        output.putString(
            "Needed for current config:",
            at: (halfWidth - 13, halfHeight + 1)
        )
        output.putString(
            "Width: \(minRequiredDim.minWidth), Height: \(minRequiredDim.minHeight)",
            at: (halfWidth - 12, halfHeight + 2)
        )
    }

    public func onResize(newPageState: PageState) async {
        self.state = newPageState
    }

}
