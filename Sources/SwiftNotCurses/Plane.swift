import Foundation
import notcurses

public class Plane {
    internal let ncplane: OpaquePointer
    public let parentPlane: Plane?

    public let notcurses: NotCurses?

    internal var opts: PlaneOptions

    private var _width: UInt32 = 0
    private var _height: UInt32 = 0

    private var _x: Int32 = 0
    private var _y: Int32 = 0

    public var debugID: String

    public let type: PlaneType

    private var _backgroundColor: Color?

    public var backgroundColor: Color? {
        get {
            _backgroundColor
        }
        set(newValue) {
            if let newValue {
                setBackgroundColor(newValue)
            } else {
                setDefaultBackgroundColor()
            }
            _backgroundColor = newValue
        }
    }

    private var _foregroundColor: Color?

    public var foregroundColor: Color? {
        get {
            _foregroundColor
        }
        set(newValue) {
            if let newValue {
                setForegroundColor(newValue)
            } else {
                setDefaultForegroundColor()
            }
            _foregroundColor = newValue
        }
    }

    public init?(in plane: Plane, opts: PlaneOptions) {  // Regular Plane
        self.opts = opts
        self.debugID = opts.debugID ?? "NOID"
        guard
            let ncplane = ncplane_create(
                plane.ncplane,
                &self.opts.ncPlaneOptions
            )
        else {
            return nil
        }
        self.ncplane = ncplane
        self.notcurses = nil
        self.parentPlane = plane
        self.type = .regular

        self.update()
        self.registerPlaneResizeCallback()
    }

    public init?(in notcurses: NotCurses) {  // STD Plane
        self.notcurses = notcurses
        self.opts = PlaneOptions()  // not used in std plane but has to be initialized
        guard let ncplane = notcurses_stdplane(notcurses.pointer) else {
            return nil
        }
        self.ncplane = ncplane
        self.debugID = "STD"
        self.parentPlane = nil
        self.type = .std

        self.update()

        self.registerPlaneResizeCallback()
    }
}

extension Plane {

    private func registerPlaneResizeCallback() {
        ncplane_set_userptr(ncplane, Unmanaged.passRetained(self).toOpaque())
        let callback: @convention(c) (OpaquePointer?) -> Int32 = {
            (ptr) -> Int32 in
            guard let ptr else {
                return -1
            }
            guard let context = ncplane_userptr(ptr) else {
                return -2
            }
            let plane = Unmanaged<Plane>.fromOpaque(context).takeRetainedValue()
            plane.resizeCallback()
            ncplane_set_userptr(
                plane.ncplane,
                Unmanaged.passRetained(plane).toOpaque()
            )  // Has to be set again for some reason...
            if let notcurses = plane.notcurses {
                notcurses.refresh()
            }
            return 0
        }
        ncplane_set_resizecb(self.ncplane, callback)
    }

    internal func resizeCallback() {
        update()
    }
}

public extension Plane {
    enum PlaneType {
        case regular
        case std
    }
}

private extension Plane {

    func updatePosition() {
        ncplane_yx(ncplane, &_y, &_x)
    }

    func updateDimensions() {
        ncplane_dim_yx(ncplane, &_height, &_width)
    }

    func update() {
        updatePosition()
        updateDimensions()
    }
}

public extension Plane {

    func resize(width: UInt32, height: UInt32) {
        ncplane_resize_simple(ncplane, height, width)
        updateDimensions()
    }

    func move(x: Int32, y: Int32) {
        ncplane_move_yx(ncplane, y, x)
        updatePosition()
    }

    func realign() {
        ncplane_resize_realign(ncplane)
        updatePosition()
    }

    func place(within plane: Plane) {
        ncplane_resize_placewithin(plane.ncplane)
        updatePosition()
    }

    func maximize() {
        ncplane_resize_maximize(ncplane)
        update()
    }

}

public extension Plane {
    var width: UInt32 {
        get {
            _width
        }
        set {
            resize(width: newValue, height: _height)
        }
    }

    var height: UInt32 {
        get {
            _height
        }
        set {
            resize(width: _width, height: newValue)
        }
    }
}

public extension Plane {
    var x: Int32 {
        get {
            _x
        }
        set {
            move(x: newValue, y: _y)
        }
    }

    var y: Int32 {
        get {
            _y
        }
        set {
            move(x: _x, y: newValue)
        }
    }
}

public extension Plane {

    func putString(_ string: String, at position: (x: Int32, y: Int32)) {
        ncplane_putstr_yx(ncplane, position.y, position.x, string)
    }

    func windowBorder(name: String? = nil, width: UInt32, height: UInt32) {
        putString(
            String(repeating: "─", count: Int(width) - 2),
            at: (1, 0)
        )
        putString("╭", at: (0, 0))
        putString("╮", at: (Int32(width) - 1, y: 0))
        for i in 1..<height - 1 {
            putString("│", at: (x: 0, y: Int32(i)))
            putString("│", at: (x: Int32(width) - 1, y: Int32(i)))
        }
        if let name {
            putString(name, at: (1, 1))
            putString("├", at: (0, 2))
            putString("┤", at: (Int32(width) - 1, 2))
            putString(
                String(repeating: "─", count: Int(width) - 2),
                at: (1, 2)
            )
        }
        putString("╰", at: (0, Int32(height) - 1))
        putString(
            "╯",
            at: (Int32(width) - 1, Int32(height) - 1)
        )
        putString(
            String(repeating: "─", count: Int(width) - 2),
            at: (1, Int32(height) - 1)
        )
    }

}

public extension Plane {

    func erase() {
        ncplane_erase(ncplane)
    }

    func blank() {
        for i in 0..<self.height {
            self.putString(
                String.init(repeating: " ", count: Int(self.width)),
                at: (0, Int32(i))
            )
        }
    }

    func destroy() {
        ncplane_destroy(ncplane)
    }

}

public extension Plane {

    func moveOnTopOfZStack() {
        ncplane_move_top(ncplane)
    }

    func moveToBottomOfZStack() {
        ncplane_move_bottom(ncplane)
    }

    func moveAbove(other plane: Plane) {
        ncplane_move_above(self.ncplane, plane.ncplane)
    }

    func moveBelow(other plane: Plane) {
        ncplane_move_below(self.ncplane, plane.ncplane)
    }
}

public extension Plane {

    func setForegroundColor(_ color: Color) {
        switch color.type {
        case .palette:
            ncplane_set_fg_palindex(ncplane, UInt32(color.paletteIndex))
        case .rgb:
            ncplane_set_fg_rgb8(ncplane, UInt32(color.red), UInt32(color.green), UInt32(color.blue))
        }
        ncplane_set_fg_alpha(ncplane, Int32(color.alpha))
        _foregroundColor = color
    }

    func setBackgroundColor(_ color: Color) {
        switch color.type {
        case .palette:
            ncplane_set_bg_palindex(ncplane, UInt32(color.paletteIndex))
        case .rgb:
            ncplane_set_bg_rgb8(ncplane, UInt32(color.red), UInt32(color.green), UInt32(color.blue))
        }
        ncplane_set_bg_alpha(ncplane, Int32(color.alpha))
        _backgroundColor = color
    }

    func setDefaultForegroundColor() {
        ncplane_set_fg_default(ncplane)
        ncplane_set_fg_alpha(ncplane, 255)
        _foregroundColor = nil
    }

    func setDefaultBackgroundColor() {
        ncplane_set_bg_default(ncplane)
        ncplane_set_bg_alpha(ncplane, 255)
        _backgroundColor = nil
    }

}
