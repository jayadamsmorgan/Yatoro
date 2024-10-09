import Foundation
import MusicKit

public actor QueuePage: Page {

    private let plane: Plane

    private var state: PageState

    private var currentQueue: ApplicationMusicPlayer.Queue.Entries?
    private var cache: [Page]

    private var maxItemsDisplayed: Int {
        (Int(self.state.height) - 3) / 6
    }

    public func onResize(newPageState: PageState) async {
        self.state = newPageState
        plane.updateByPageState(state)
        self.currentQueue = nil
    }

    public func getPageState() async -> PageState { self.state }

    public func getMaxDimensions() async -> (width: UInt32, height: UInt32)? { nil }

    public func getMinDimensions() async -> (width: UInt32, height: UInt32) { (23, 17) }

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
        self.cache = []
        self.currentQueue = nil
    }

    public func render() async {

        plane.erase()

        plane.windowBorder(name: "Player Queue:", state: state)

        guard currentQueue != Player.shared.queue else {
            return
        }
        for case let item as SongItemPage in cache {
            await item.destroy()
        }
        cache = []
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
                self.cache.append(page)
            default: break
            }
        }
        for itemIndex in cache.indices {
            if itemIndex >= maxItemsDisplayed {
                break
            }
            await cache[itemIndex].render()

        }

    }

}
