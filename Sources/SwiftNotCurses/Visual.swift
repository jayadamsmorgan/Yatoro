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

    public enum BlitConfig: String, Codable {
        case `default`
        case oneByOne
        case twoByOne
        case twoByTwo
        case threeByTwo
        case fourByTwo
        case braille
        case pixel
        case fourByOne
        case eightByOne

        fileprivate func toBlitter() -> ncblitter_e {
            switch self {
            case .default: return NCBLIT_DEFAULT
            case .oneByOne: return NCBLIT_1x1
            case .twoByOne: return NCBLIT_2x1
            case .twoByTwo: return NCBLIT_2x2
            case .threeByTwo: return NCBLIT_3x2
            case .fourByTwo: return NCBLIT_4x2
            case .braille: return NCBLIT_BRAILLE
            case .pixel: return NCBLIT_PIXEL
            case .fourByOne: return NCBLIT_4x1
            case .eightByOne: return NCBLIT_8x1
            }
        }
    }

    public init?(
        in notcurses: NotCurses,
        width: Int32,
        height: Int32,
        from rgba: [UInt8],
        for plane: Plane,
        blit: BlitConfig = .default
    ) {
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
            blitter: blit.toBlitter(),
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
