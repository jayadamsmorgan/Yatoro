import SwiftNotCurses

extension PlaneOptions {

    public convenience init(
        pageState: PageState,
        debugID: String? = nil,
        flags: [PlaneOptionFlags] = [],
        bottomMargin: UInt32 = 0,
        rightMargin: UInt32 = 0
    ) {
        self.init(
            x: pageState.absX,
            y: pageState.absY,
            width: pageState.width,
            height: pageState.height,
            debugID: debugID,
            flags: flags,
            bottomMargin: bottomMargin,
            rightMargin: rightMargin
        )
    }
}
