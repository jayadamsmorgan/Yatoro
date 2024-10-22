import notcurses

// TODO: NEEDS HARD REWORK,
// VERY TEMPORARY SOLUTION JUST FOR YATORO SONG ARTWORKS
public struct Visual {

    internal let pointer: OpaquePointer
    internal var opts: ncvisual_options
    internal let notcurses: NotCurses

    public let width: Int32
    public let height: Int32

    public let plane: Plane
    private var rgba: [UInt8]
    private var renderPlane: OpaquePointer?

    public init?(in notcurses: NotCurses, width: Int32, height: Int32, from rgba: [UInt8], for plane: Plane) {
        self.rgba = rgba
        var pointer: OpaquePointer?
        self.rgba.withUnsafeBytes { bufPtr in
            guard let ptr = ncvisual_from_rgba(bufPtr.baseAddress!, width, 4 * width, height) else {
                return
            }
            pointer = ptr
        }
        guard let pointer else { return nil }
        self.pointer = pointer
        self.width = width
        self.height = height
        self.notcurses = notcurses
        self.plane = plane
        self.opts = .init(
            n: plane.ncplane,
            scaling: NCSCALE_STRETCH,
            y: 2,
            x: 2,
            begy: 0,
            begx: 0,
            leny: 0,
            lenx: 0,
            blitter: NCBLIT_PIXEL,
            flags: NCVISUAL_OPTION_CHILDPLANE | NCVISUAL_OPTION_VERALIGNED | NCVISUAL_OPTION_HORALIGNED,
            transcolor: 0,
            pxoffy: 0,
            pxoffx: 0
        )
    }

    public mutating func render() {
        self.renderPlane = ncvisual_blit(notcurses.pointer, pointer, &opts)
    }

    public mutating func destroy() {
        if let renderPlane {
            ncplane_destroy(renderPlane)
            self.renderPlane = nil
            ncvisual_destroy(self.pointer)
        }
    }

}
