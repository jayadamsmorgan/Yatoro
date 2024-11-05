import MusicKit
import SwiftNotCurses

@MainActor
public class RecommendationItemPage: DestroyablePage {

    private var state: PageState
    private let plane: Plane

    private let borderPlane: Plane
    private let pageNamePlane: Plane
    private let refreshDateLeftPlane: Plane
    private let refreshDateRightPlane: Plane?
    private let titleLeftPlane: Plane
    private let titleRightPlane: Plane?
    private let typesLeftPlane: Plane
    private let typesRightPlane: Plane

    private let item: MusicPersonalRecommendation

    public func getItem() async -> MusicPersonalRecommendation { item }

    public init?(
        in plane: Plane,
        state: PageState,
        colorConfig: Config.UIConfig.Colors.RecommendationItem,
        item: MusicPersonalRecommendation
    ) {
        self.state = state
        guard
            let pagePlane = Plane(
                in: plane,
                opts: .init(
                    pageState: state,
                    debugID: "RECOMMENDATION_UI_\(item.id)",
                    flags: []
                )
            )
        else {
            return nil
        }
        pagePlane.backgroundColor = colorConfig.page.background
        pagePlane.foregroundColor = colorConfig.page.foreground
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
                debugID: "RECOMMENDATION_UI_\(item.id)_BORDER"
            )
        else {
            return nil
        }
        borderPlane.backgroundColor = colorConfig.border.background
        borderPlane.foregroundColor = colorConfig.border.foreground
        borderPlane.windowBorder(width: state.width, height: state.height)
        self.borderPlane = borderPlane

        guard
            let pageNamePlane = Plane(
                in: pagePlane,
                state: .init(
                    absX: 3,
                    absY: 0,
                    width: 14,
                    height: 1
                ),
                debugID: "RECOMMENDATION_UI_\(item.id)_PN"
            )
        else {
            return nil
        }
        pageNamePlane.backgroundColor = colorConfig.pageName.background
        pageNamePlane.foregroundColor = colorConfig.pageName.foreground
        pageNamePlane.putString("Recommendation", at: (0, 0))
        self.pageNamePlane = pageNamePlane

        guard
            let titleLeftPlane = Plane(
                in: pagePlane,
                state: .init(
                    absX: 2,
                    absY: 1,
                    width: 6,
                    height: 1
                ),
                debugID: "RECOMMENDATION_UI_\(item.id)_GL"
            )
        else {
            return nil
        }
        titleLeftPlane.backgroundColor = colorConfig.titleLeft.background
        titleLeftPlane.foregroundColor = colorConfig.titleLeft.foreground
        titleLeftPlane.putString("Title:", at: (0, 0))
        self.titleLeftPlane = titleLeftPlane

        if let title = item.title {
            let titleRightWidth = min(UInt32(title.count), state.width - 10)
            guard
                let titleRightPlane = Plane(
                    in: pagePlane,
                    state: .init(
                        absX: 9,
                        absY: 1,
                        width: titleRightWidth,
                        height: 1
                    ),
                    debugID: "RECOMMENDATION_UI_\(item.id)_GR"
                )
            else {
                return nil
            }
            titleRightPlane.backgroundColor = colorConfig.titleRight.background
            titleRightPlane.foregroundColor = colorConfig.titleRight.foreground
            titleRightPlane.putString(title, at: (0, 0))
            self.titleRightPlane = titleRightPlane
        } else {
            self.titleRightPlane = nil
        }

        guard
            let typesLeftPlane = Plane(
                in: pagePlane,
                state: .init(
                    absX: 2,
                    absY: 3,
                    width: 6,
                    height: 1
                ),
                debugID: "RECOMMENDATION_UI_\(item.id)_ALL"
            )
        else {
            return nil
        }
        typesLeftPlane.backgroundColor = colorConfig.typesLeft.background
        typesLeftPlane.foregroundColor = colorConfig.typesLeft.foreground
        typesLeftPlane.putString("Types:", at: (0, 0))
        self.typesLeftPlane = typesLeftPlane

        var typesStr = ""
        for type in item.types {
            typesStr.append("\(type), ")
        }
        if typesStr.count >= 2 {
            typesStr.removeLast(2)
        }
        let typesRightWidth = min(UInt32(typesStr.count), state.width - 10)
        guard
            let typesRightPlane = Plane(
                in: pagePlane,
                state: .init(
                    absX: 9,
                    absY: 3,
                    width: typesRightWidth,
                    height: 1
                ),
                debugID: "RECOMMENDATION_UI_\(item.id)_ALR"
            )
        else {
            return nil
        }
        typesRightPlane.backgroundColor = colorConfig.typesRight.background
        typesRightPlane.foregroundColor = colorConfig.typesRight.foreground
        typesRightPlane.putString(typesStr, at: (0, 0))
        self.typesRightPlane = typesRightPlane

        guard
            let refreshDateLeftPlane = Plane(
                in: pagePlane,
                state: .init(
                    absX: 2,
                    absY: 2,
                    width: 8,
                    height: 1
                ),
                debugID: "RECOMMENDATION_UI_\(item.id)_ARL"
            )
        else {
            return nil
        }
        refreshDateLeftPlane.backgroundColor = colorConfig.refreshDateLeft.background
        refreshDateLeftPlane.foregroundColor = colorConfig.refreshDateLeft.foreground
        refreshDateLeftPlane.putString("Refresh:", at: (0, 0))
        self.refreshDateLeftPlane = refreshDateLeftPlane

        if let refreshDate = item.nextRefreshDate?.formatted() {
            let refreshDateRightWidth = min(UInt32(refreshDate.count), state.width - 12)
            guard
                let refreshDateRightPlane = Plane(
                    in: pagePlane,
                    state: .init(
                        absX: 11,
                        absY: 2,
                        width: refreshDateRightWidth,
                        height: 1
                    ),
                    debugID: "RECOMMENDATION_UI_\(item.id)_ARR"
                )
            else {
                return nil
            }
            refreshDateRightPlane.backgroundColor = colorConfig.refreshDateRight.background
            refreshDateRightPlane.foregroundColor = colorConfig.refreshDateRight.foreground
            refreshDateRightPlane.putString(refreshDate, at: (0, 0))
            self.refreshDateRightPlane = refreshDateRightPlane
        } else {
            self.refreshDateRightPlane = nil
        }

        self.item = item

    }

    public func destroy() async {
        plane.erase()
        plane.destroy()

        borderPlane.erase()
        borderPlane.destroy()

        pageNamePlane.erase()
        pageNamePlane.destroy()

        refreshDateLeftPlane.erase()
        refreshDateLeftPlane.destroy()
        refreshDateRightPlane?.erase()
        refreshDateRightPlane?.destroy()

        titleLeftPlane.erase()
        titleLeftPlane.destroy()
        titleRightPlane?.erase()
        titleRightPlane?.destroy()

        typesLeftPlane.erase()
        typesLeftPlane.destroy()
        typesRightPlane.erase()
        typesRightPlane.destroy()
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
