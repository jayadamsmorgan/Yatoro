import Logging
import SwiftNotCurses

@MainActor
public class WindowTooSmallPage: Page {

    private let plane: Plane

    private var state: PageState

    private var minRequiredDim: (minWidth: UInt32, minHeight: UInt32) = (0, 0)

    public func setMinRequiredDim(
        _ minRequiredDim: (minWidth: UInt32, minHeight: UInt32)
    ) async {
        self.minRequiredDim = minRequiredDim
    }

    public func getPageState() async -> PageState { self.state }

    public func getMinDimensions() async -> (width: UInt32, height: UInt32) { (0, 0) }

    public func getMaxDimensions() async -> (width: UInt32, height: UInt32)? { nil }

    public init?(stdPlane: Plane) {
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
                )
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
    }

    public func windowTooSmall() -> Bool {
        return (self.state.height - 2 < minRequiredDim.minHeight)
            || (self.state.width < minRequiredDim.minWidth)
    }

    public func render() async {
        plane.erase()

        guard windowTooSmall() else {
            plane.moveToBottomOfZStack()
            return
        }
        plane.moveOnTopOfZStack()

        for i in 0..<self.state.height {
            plane.putString(
                String(repeating: " ", count: Int(self.state.width)),
                at: (0, Int32(i))
            )
        }
        let halfWidth = Int32(state.width) / 2
        let halfHeight = Int32(state.height) / 2
        plane.putString(
            "Terminal size too small:",
            at: (halfWidth - 12, halfHeight - 2)
        )
        plane.putString(
            "Width: \(state.width), Height: \(state.height)",
            at: (halfWidth - 12, halfHeight - 1)
        )
        plane.putString(
            "Needed for current config:",
            at: (halfWidth - 13, halfHeight + 1)
        )
        plane.putString(
            "Width: \(minRequiredDim.minWidth), Height: \(minRequiredDim.minHeight)",
            at: (halfWidth - 12, halfHeight + 2)
        )
    }

    public func onResize(newPageState: PageState) async {
        self.state = newPageState
    }

}
