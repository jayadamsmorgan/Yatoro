import Foundation
import Logging
import notcurses

public class BlockingQueue<T> {
    private var queue = [T]()
    private let semaphore = DispatchSemaphore(value: 0)
    private let accessQueue = DispatchQueue(label: "dev.hermanberdnikov.yatoro.blockingQueue")

    func enqueue(_ element: T) {
        accessQueue.async {
            self.queue.append(element)
            self.semaphore.signal()
        }
    }

    func dequeue() -> T {
        semaphore.wait()
        var element: T?
        accessQueue.sync {
            element = self.queue.removeFirst()
        }
        return element!
    }
}

public class InputQueue {

    public var mappings: [Mapping]

    private var queue: BlockingQueue<Input>

    private var logger: Logger?

    public func add(_ newInput: Input) {
        queue.enqueue(newInput)
    }

    public init(mappings: [Mapping], logger: Logger?) {
        self.mappings = mappings
        self.queue = .init()
        self.logger = logger
    }

    public func loadMappings() {
        logger?.trace("Loading mappings...")

    }

    public func start() async {
        Task {
            while (true) {
                let input = self.queue.dequeue()
                guard
                    let mapping = mappings.first(where: {
                        if var modifiers = $0.modifiers, modifiers.contains(.shift) {
                            modifiers.removeAll(where: { $0 == .shift })
                            return $0.key.uppercased() == input.utf8 && modifiers == input.modifiers
                        }
                        return $0.key.uppercased() == input.utf8.uppercased()
                            && ($0.modifiers == input.modifiers || $0.modifiers == nil && input.modifiers.isEmpty)
                    })
                else {
                    continue
                }
                switch mapping.action {
                case .playPauseToggle:
                    await Player.shared.playPauseToggle()
                case .play:
                    await Player.shared.play()
                case .pause:
                    Player.shared.pause()
                case .stop:
                    // TODO
                    break
                case .clearQueue:
                    await Player.shared.clearQueue()
                case .playNext:
                    await Player.shared.playNext()
                case .startSeekingForward:
                    // TODO
                    break
                case .playPrevious:
                    await Player.shared.playPrevious()
                case .startSeekingBackward:
                    // TODO
                    break
                case .restartSong:
                    await Player.shared.restartSong()
                case .startSearching:
                    // TODO
                    break
                case .openCommmandLine:
                    // TODO
                    break
                case .quitApplication:
                    UI.running = false  // I don't like it but it's ok for now
                }
            }
        }
    }

}
