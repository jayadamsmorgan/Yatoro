import Foundation
import MusicKit
import notcurses

public actor QueuePage: Page {

    private let plane: Plane

    private let output: Output

    private var state: PageState

    private var currentQueue: ApplicationMusicPlayer.Queue.Entries?
    private var searchCache: [Page]

    private var maxItemsDisplayed: Int {
        (Int(self.state.height) - 4) / 6
    }

    public func onResize(newPageState: PageState) async {
        self.state = newPageState
        ncplane_move_yx(plane.ncplane, state.absY, state.absX)
        ncplane_resize_simple(plane.ncplane, state.height, state.width)
        var counter = 0
        for itemIndex in searchCache.indices {
            let height = await searchCache[itemIndex].getPageState().height
            let y = 3 + Int32(itemIndex) * Int32(height)
            await searchCache[itemIndex].onResize(
                newPageState: .init(
                    absX: 1,
                    absY: y,
                    width: self.state.width - 2,
                    height: height
                )
            )
            counter += 1
            if counter < maxItemsDisplayed {
                await searchCache[itemIndex].render()
            }
        }
    }

    public func getPageState() async -> PageState {
        self.state
    }

    public func getMaxDimensions() async -> (width: UInt32, height: UInt32)? {
        nil
    }

    public func getMinDimensions() async -> (width: UInt32, height: UInt32) {
        (23, 17)
    }

    public init?(stdPlane: Plane, state: PageState) {
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
        self.plane = plane
        self.output = .init(plane: plane)
        self.searchCache = []
        self.currentQueue = nil
    }

    public func render() async {

        ncplane_erase(plane.ncplane)

        output.windowBorder(name: "Player Queue:", state: state)

        if currentQueue != Player.shared.queue {
            logger?.debug("refresh")
            for item in searchCache {
                if let item = item as? SongItemPage {
                    await item.destroy()
                }
            }
            searchCache = []
            currentQueue = Player.shared.queue
            var i = 0
            for item in currentQueue! {
                switch item.item {
                case .song(let song):
                    guard
                        let page = SongItemPage(
                            in: self.plane,
                            state: .init(
                                absX: 1,
                                absY: 3 + Int32(i) * 6,
                                width: state.width - 2,
                                height: 6
                            ),
                            item: song
                        )
                    else {
                        continue
                    }
                    i += 1
                    self.searchCache.append(page)
                default: break
                }
            }
        }

        var counter = 0
        for itemIndex in searchCache.indices {
            if counter >= maxItemsDisplayed {
                break
            }
            await searchCache[itemIndex].render()
            counter += 1
        }

    }

}
