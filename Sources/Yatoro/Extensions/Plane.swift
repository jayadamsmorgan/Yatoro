import SwiftNotCurses

public extension Plane {

    func updateByPageState(_ state: PageState) {
        move(x: state.absX, y: state.absY)
        resize(width: state.width, height: state.height)
    }

    convenience init?(in plane: Plane, state: PageState, debugID: String) {
        self.init(in: plane, opts: .init(pageState: state, debugID: debugID))
    }

    func setColorPair(_ pair: Config.UIConfig.Colors.ColorPair) {
        self.backgroundColor = pair.background
        self.foregroundColor = pair.foreground
    }

}
