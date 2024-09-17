import Logging
import notcurses

public protocol Page {
    var plane: Plane { get set }
    var logger: Logger? { get }

    func onResize()

    func render()
}

public extension Page {
    func show() {
        ncplane_move_top(self.plane.ncplane)
        logger?.debug("Showing page with debugID \(plane.debugID)")
    }
}
