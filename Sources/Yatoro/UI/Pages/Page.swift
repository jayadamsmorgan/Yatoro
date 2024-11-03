import Logging

@MainActor
public protocol Page {

    func render() async

    func onResize(newPageState: PageState) async

    func getPageState() async -> PageState

    func getMinDimensions() async -> (width: UInt32, height: UInt32)
    func getMaxDimensions() async -> (width: UInt32, height: UInt32)?
}

public protocol DestroyablePage: Page {

    func destroy() async

}

public enum PageSize {
    case nano
    case mini
    case `default`
    case plus
    case mega
}

public struct PageState: Sendable {

    public var absX: Int32
    public var absY: Int32

    public var width: UInt32
    public var height: UInt32

    public init(
        absX: Int32,
        absY: Int32,
        width: UInt32,
        height: UInt32
    ) {
        self.absX = absX
        self.absY = absY
        self.width = width
        self.height = height
    }
}
