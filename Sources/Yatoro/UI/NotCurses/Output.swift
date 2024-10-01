import notcurses

public struct Output {

    public init(plane: Plane) {
        self.plane = plane
    }

    public let plane: Plane

    func putString(_ string: String, at position: (x: Int32, y: Int32)) {
        ncplane_putstr_yx(plane.ncplane, position.y, position.x, string)
    }

    func windowBorder(name: String? = nil, state: PageState) {
        putString(
            String(repeating: "─", count: Int(state.width) - 2),
            at: (1, 0)
        )
        putString("╭", at: (0, 0))
        putString("╮", at: (Int32(state.width) - 1, y: 0))
        for i in 1..<state.height - 1 {
            putString("│", at: (x: 0, y: Int32(i)))
            putString("│", at: (x: Int32(state.width) - 1, y: Int32(i)))
        }
        if let name {
            putString(name, at: (1, 1))
            putString("├", at: (0, 2))
            putString("┤", at: (Int32(state.width) - 1, 2))
            putString(
                String(repeating: "─", count: Int(state.width) - 2),
                at: (1, 2)
            )
        }
        putString("╰", at: (0, Int32(state.height) - 1))
        putString(
            "╯",
            at: (Int32(state.width) - 1, Int32(state.height) - 1)
        )
        putString(
            String(repeating: "─", count: Int(state.width) - 2),
            at: (1, Int32(state.height) - 1)
        )
    }

}
