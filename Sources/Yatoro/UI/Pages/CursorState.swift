public struct CursorState {
    public var x: Int32
    public var y: Int32
    public var enabled: Bool

    public init(_ pair: (x: Int32, y: Int32), enabled: Bool) {
        self.x = pair.x
        self.y = pair.y
        self.enabled = enabled
    }
}
