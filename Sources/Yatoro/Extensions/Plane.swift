import SwiftNotCurses

public extension Plane {

    func updateByPageState(_ state: PageState) {
        move(x: state.absX, y: state.absY)
        resize(width: state.width, height: state.height)
    }

}
