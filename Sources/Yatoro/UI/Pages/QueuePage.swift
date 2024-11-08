import Foundation
import MusicKit
import SwiftNotCurses

@MainActor
public class QueuePage: Page {

    private let plane: Plane
    private let borderPlane: Plane
    private let pageNamePlane: Plane

    private let shufflePlane: Plane
    private let repeatPlane: Plane

    private var state: PageState

    private var currentQueue: ApplicationMusicPlayer.Queue.Entries?
    private var cache: [Page]

    private let colorConfig: Config.UIConfig.Colors.Queue

    private var maxItemsDisplayed: Int {
        (Int(self.state.height) - 7) / 5
    }

    public func onResize(newPageState: PageState) async {
        self.state = newPageState

        plane.updateByPageState(state)
        plane.blank()

        borderPlane.updateByPageState(.init(absX: 0, absY: 0, width: state.width, height: state.height))
        borderPlane.erase()
        borderPlane.windowBorder(width: state.width, height: state.height)

        shufflePlane.updateByPageState(
            .init(
                absX: Int32(state.width) - 24,
                absY: Int32(state.height) - 1,
                width: 11,
                height: 1
            )
        )
        repeatPlane.updateByPageState(
            .init(
                absX: Int32(state.width) - 12,
                absY: Int32(state.height) - 1,
                width: 11,
                height: 1
            )
        )

        self.currentQueue = nil
    }

    public func getPageState() async -> PageState { self.state }

    public func getMaxDimensions() async -> (width: UInt32, height: UInt32)? { nil }

    public func getMinDimensions() async -> (width: UInt32, height: UInt32) { (23, 17) }

    public init?(stdPlane: Plane, state: PageState, colorConfig: Config.UIConfig.Colors.Queue) {
        self.state = state
        guard
            let plane = Plane(
                in: stdPlane,
                opts: .init(
                    x: 30,
                    y: 0,
                    width: state.width,
                    height: state.height - 3,
                    debugID: "QUEUE_PAGE",
                    flags: [.fixed]
                )
            )
        else {
            return nil
        }
        plane.backgroundColor = colorConfig.page.background
        plane.foregroundColor = colorConfig.page.foreground
        plane.blank()
        self.plane = plane

        guard
            let borderPlane = Plane(
                in: plane,
                state: .init(
                    absX: 0,
                    absY: 0,
                    width: state.width,
                    height: state.height
                ),
                debugID: "QUEUE_BORDER"
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
                in: plane,
                state: .init(
                    absX: 2,
                    absY: 0,
                    width: 12,
                    height: 1
                ),
                debugID: "QUEUE_PAGE_NAME"
            )
        else {
            return nil
        }
        pageNamePlane.backgroundColor = colorConfig.pageName.background
        pageNamePlane.foregroundColor = colorConfig.pageName.foreground
        pageNamePlane.putString("Player Queue", at: (0, 0))
        self.pageNamePlane = pageNamePlane

        guard
            let shufflePlane = Plane(
                in: plane,
                state: .init(
                    absX: Int32(state.width) - 12,
                    absY: Int32(state.height) - 2,
                    width: 11,
                    height: 1
                ),
                debugID: "QUEUE_PAGE_SH"
            )
        else {
            return nil
        }
        shufflePlane.backgroundColor = colorConfig.shuffleMode.background
        shufflePlane.foregroundColor = colorConfig.shuffleMode.foreground
        self.shufflePlane = shufflePlane

        guard
            let repeatPlane = Plane(
                in: plane,
                state: .init(
                    absX: Int32(state.width) - 12,
                    absY: Int32(state.height) - 2,
                    width: 10,
                    height: 1
                ),
                debugID: "QUEUE_PAGE_RE"
            )
        else {
            return nil
        }
        repeatPlane.backgroundColor = colorConfig.repeatMode.background
        repeatPlane.foregroundColor = colorConfig.repeatMode.foreground
        self.repeatPlane = repeatPlane

        self.cache = []
        self.currentQueue = nil
        self.colorConfig = colorConfig
    }

    public func render() async {

        switch Player.shared.player.state.repeatMode {
        case Optional.none, .some(.none):
            repeatPlane.width = 10
            repeatPlane.putString("Repeat:Off", at: (0, 0))
        case .one:
            repeatPlane.width = 10
            repeatPlane.putString("Repeat:One", at: (0, 0))
        case .all:
            repeatPlane.width = 10
            repeatPlane.putString("Repeat:All", at: (0, 0))
        @unknown default:
            logger?.error("QueuePage: Unhandled repeat mode.")
        }

        switch Player.shared.player.state.shuffleMode {
        case Optional.none, .off:
            shufflePlane.width = 11
            shufflePlane.putString("Shuffle:Off", at: (0, 0))
        case .songs:
            shufflePlane.width = 10
            shufflePlane.putString("Shuffle:On", at: (0, 0))
        @unknown default:
            logger?.error("QueuePage: Unhandled shuffle mode.")
        }

        guard currentQueue != Player.shared.queue else {
            return
        }
        logger?.debug("Queue UI update")
        for case let item as SongItemPage in cache {
            await item.destroy()
        }
        cache = []
        currentQueue = Player.shared.queue
        var i = 0
        for itemIndex in currentQueue!.indices {
            switch currentQueue![itemIndex].item {
            case .song(let song):
                guard
                    let page = SongItemPage(
                        in: self.plane,
                        state: .init(
                            absX: 1,
                            absY: 1 + Int32(i) * 5,
                            width: state.width - 2,
                            height: 5
                        ),
                        colorConfig: colorConfig.songItem,
                        item: song
                    )
                else {
                    continue
                }
                i += 1
                self.cache.append(page)
            default: break
            }
            if itemIndex >= maxItemsDisplayed {
                break
            }
        }

    }

}
