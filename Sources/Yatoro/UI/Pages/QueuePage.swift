import Foundation
import MusicKit
import notcurses

public actor QueuePage: Page {

    private let plane: Plane

    private let output: Output

    private var state: PageState

    private var currentQueue: ApplicationMusicPlayer.Queue.Entries?
    private var cache: [Page]

    private var maxItemsDisplayed: Int {
        (Int(self.state.height) - 3) / 6
    }

    public func onResize(newPageState: PageState) async {
        self.state = newPageState
        ncplane_move_yx(plane.ncplane, state.absY, state.absX)
        ncplane_resize_simple(plane.ncplane, state.height, state.width)
        self.currentQueue = nil
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
        self.cache = []
        self.currentQueue = nil
    }

    public func render() async {

        ncplane_erase(plane.ncplane)

        output.windowBorder(name: "Player Queue:", state: state)

        guard currentQueue != Player.shared.queue else {
            return
        }
        for item in cache {
            if let item = item as? SongItemPage {
                await item.destroy()
            }
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
        var counter = 0
        for itemIndex in cache.indices {
            if counter >= maxItemsDisplayed {
                break
            }
            await cache[itemIndex].render()
            counter += 1

        }

    }

}
