import Logging
import notcurses

public struct SearchPage: Page {

    public var plane: Plane
    public var logger: Logger?

    private let output: Output

    public let width: UInt32 = 28
    public let height: UInt32 = 13

    public init?(stdPlane: Plane, logger: Logger?) {
        guard
            let plane = Plane(
                in: stdPlane,
                opts: .init(
                    x: 0,
                    y: 0,
                    width: width,
                    height: height,
                    debugID: "SEARCH_PAGE",
                    flags: [.verticalScrolling]
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
    }

}
