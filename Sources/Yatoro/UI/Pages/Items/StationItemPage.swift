import MusicKit
import SwiftNotCurses

@MainActor
public class StationItemPage: DestroyablePage {

    private var state: PageState
    private let plane: Plane

    private let borderPlane: Plane
    private let pageNamePlane: Plane
    private let notesLeftPlane: Plane
    private let notesRightPlane: Plane
    private let isLiveLeftPlane: Plane
    private let isLiveRightPlane: Plane
    private let stationLeftPlane: Plane
    private let stationRightPlane: Plane

    private let item: Station

    public func getItem() async -> Station { item }

    public init?(
        in plane: Plane,
        state: PageState,
        item: Station
    ) {
        self.state = state
        guard
            let pagePlane = Plane(
                in: plane,
                opts: .init(
                    pageState: state,
                    debugID: "STATION_UI_\(item.id)",
                    flags: []
                )
            )
        else {
            return nil
        }
        self.plane = pagePlane

        guard
            let borderPlane = Plane(
                in: pagePlane,
                state: .init(
                    absX: 0,
                    absY: 0,
                    width: state.width,
                    height: state.height
                ),
                debugID: "STATION_UI_\(item.id)_BORDER"
            )
        else {
            return nil
        }
        borderPlane.windowBorder(width: state.width, height: state.height)
        self.borderPlane = borderPlane

        guard
            let pageNamePlane = Plane(
                in: pagePlane,
                state: .init(
                    absX: 3,
                    absY: 0,
                    width: 7,
                    height: 1
                ),
                debugID: "STATION_UI_\(item.id)_PN"
            )
        else {
            return nil
        }
        pageNamePlane.putString("Station", at: (0, 0))
        self.pageNamePlane = pageNamePlane

        guard
            let stationLeftPlane = Plane(
                in: pagePlane,
                state: .init(
                    absX: 2,
                    absY: 1,
                    width: 8,
                    height: 1
                ),
                debugID: "STATION_UI_\(item.id)_SL"
            )
        else {
            return nil
        }
        stationLeftPlane.putString("Station:", at: (0, 0))
        self.stationLeftPlane = stationLeftPlane

        let stationRightWidth = min(UInt32(item.name.count), state.width - 12)
        guard
            let stationRightPlane = Plane(
                in: pagePlane,
                state: .init(
                    absX: 11,
                    absY: 1,
                    width: stationRightWidth,
                    height: 1
                ),
                debugID: "STATION_UI_\(item.id)_SR"
            )
        else {
            return nil
        }
        stationRightPlane.putString(item.name, at: (0, 0))
        self.stationRightPlane = stationRightPlane

        guard
            let notesLeftPlane = Plane(
                in: pagePlane,
                state: .init(
                    absX: 2,
                    absY: 3,
                    width: 6,
                    height: 1
                ),
                debugID: "STATION_UI_\(item.id)_DL"
            )
        else {
            return nil
        }
        notesLeftPlane.putString("Notes:", at: (0, 0))
        self.notesLeftPlane = notesLeftPlane

        var notesRightWidth = min(UInt32(item.editorialNotes?.standard?.count ?? 1), state.width - 10)
        if notesRightWidth == 0 { notesRightWidth = 1 }
        guard
            let notesRightPlane = Plane(
                in: pagePlane,
                state: .init(
                    absX: 9,
                    absY: 3,
                    width: notesRightWidth,
                    height: 1
                ),
                debugID: "STATION_UI_\(item.id)_DR"
            )
        else {
            return nil
        }
        notesRightPlane.putString(item.editorialNotes?.standard ?? "", at: (0, 0))
        self.notesRightPlane = notesRightPlane

        guard
            let isLiveLeftPlane = Plane(
                in: pagePlane,
                state: .init(
                    absX: 2,
                    absY: 2,
                    width: 7,
                    height: 1
                ),
                debugID: "STATION_UI_\(item.id)_CL"
            )
        else {
            return nil
        }
        isLiveLeftPlane.putString("IsLive:", at: (0, 0))
        self.isLiveLeftPlane = isLiveLeftPlane

        let isLiveRightWidth = min(UInt32("\(item.isLive)".count), state.width - 11)
        guard
            let isLiveRightPlane = Plane(
                in: pagePlane,
                state: .init(
                    absX: 10,
                    absY: 2,
                    width: isLiveRightWidth,
                    height: 1
                ),
                debugID: "STATION_UI_\(item.id)_CR"
            )
        else {
            return nil
        }
        isLiveRightPlane.putString("\(item.isLive)", at: (0, 0))
        self.isLiveRightPlane = isLiveRightPlane

        self.item = item

        updateColors()
    }

    public func updateColors() {
        let colorConfig = Config.shared.ui.colors.search.stationItem
        plane.setColorPair(colorConfig.page)
        borderPlane.setColorPair(colorConfig.border)
        pageNamePlane.setColorPair(colorConfig.pageName)
        stationLeftPlane.setColorPair(colorConfig.stationLeft)
        stationRightPlane.setColorPair(colorConfig.stationRight)
        notesLeftPlane.setColorPair(colorConfig.notesLeft)
        notesRightPlane.setColorPair(colorConfig.notesRight)
        isLiveLeftPlane.setColorPair(colorConfig.isLiveLeft)
        isLiveRightPlane.setColorPair(colorConfig.isLiveRight)
    }

    public func destroy() async {
        plane.erase()
        plane.destroy()

        borderPlane.erase()
        borderPlane.destroy()

        pageNamePlane.erase()
        pageNamePlane.destroy()

        isLiveLeftPlane.erase()
        isLiveLeftPlane.destroy()
        isLiveRightPlane.erase()
        isLiveRightPlane.destroy()

        notesLeftPlane.erase()
        notesLeftPlane.destroy()
        notesRightPlane.erase()
        notesRightPlane.destroy()

        stationLeftPlane.erase()
        stationLeftPlane.destroy()
        stationRightPlane.erase()
        stationRightPlane.destroy()
    }

    public func render() async {

    }

    public func onResize(newPageState: PageState) async {
        self.state = newPageState
        plane.updateByPageState(state)
        plane.blank()

        borderPlane.updateByPageState(state)
        borderPlane.erase()
        borderPlane.windowBorder(width: state.width, height: state.height)
    }

    public func getPageState() async -> PageState { state }

    public func getMinDimensions() async -> (width: UInt32, height: UInt32) { (12, state.height) }

    public func getMaxDimensions() async -> (width: UInt32, height: UInt32)? { nil }

}
