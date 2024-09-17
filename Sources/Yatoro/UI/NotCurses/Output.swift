import notcurses

public struct Output {

    public init(plane: Plane) {
        self.plane = plane
    }

    public let plane: Plane

    func putString(_ string: String, at position: (x: Int32, y: Int32)) {
        ncplane_putstr_yx(plane.ncplane, position.y, position.x, string)
    }

}
