import notcurses

// TODO: NEEDS HARD REWORK,
// VERY TEMPORARY SOLUTION JUST FOR YATORO SONG ARTWORKS
public struct Visual {

    internal let pointer: OpaquePointer
    internal var opts: ncvisual_options
    internal let notcurses: NotCurses

    public let plane: Plane

    public init?(in notcurses: NotCurses, from rgba: [UInt8], for plane: Plane) {
        guard let ptr = ncvisual_from_rgba(rgba, 50, 50 * 4, 50) else {
            return nil
        }
        self.notcurses = notcurses
        self.plane = plane
        self.pointer = ptr
        self.opts = .init(
            n: plane.ncplane,
            scaling: NCSCALE_STRETCH,
            y: Int32(NCALIGN_CENTER.rawValue),
            x: Int32(NCALIGN_CENTER.rawValue),
            begy: 0,
            begx: 0,
            leny: 0,
            lenx: 0,
            blitter: NCBLIT_PIXEL,
            flags: 0,
            transcolor: 0,
            pxoffy: 0,
            pxoffx: 0
        )
    }

    public mutating func render() {
        ncvisual_blit(notcurses.pointer, pointer, &opts)
    }

}
