import Logging
import notcurses

public protocol Page {
    var plane: Plane { get set }
    var logger: Logger? { get }

    var width: UInt32 { get set }
    var height: UInt32 { get set }

    func render() async
}

public extension Page {

    func show() {
        logger?.trace("Showing page with debugID \(plane.debugID)")
        ncplane_move_top(self.plane.ncplane)
        logger?.debug("Showed page with debugID \(plane.debugID)")
    }
}
