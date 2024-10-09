import Foundation
import Logging
import SwiftNotCurses
import notcurses

public actor InputQueue {

    public var mappings: [Mapping]

    private var queue: BlockingQueue<Input>

    public func add(_ newInput: Input) {
        Task {
            await queue.enqueue(newInput)
        }
    }

    public init(mappings: [Mapping]) {
        self.mappings = mappings
        self.queue = .init()
    }

    public func start() async {
        Task {
            while (true) {
                let input = await self.queue.dequeue()

                guard UI.mode == .normal else {
                    // CMD mode
                    await CommandInput.shared.setLastCommandOutput("")
                    guard input.id != 27 else {
                        // ESC pressed
                        UI.mode = .normal
                        await CommandInput.shared.clear()
                        continue
                    }
                    guard input.id != 1115121 else {
                        // Enter pressed
                        UI.mode = .normal
                        await Command.parseCommand()
                        await CommandInput.shared.clear()
                        continue
                    }
                    let commandInput = await CommandInput.shared.get()
                    if input.id == 1115008 && commandInput.isEmpty {
                        // Backspace pressed when the command input is empty
                        UI.mode = .normal
                        continue
                    }
                    await CommandInput.shared.add(input)
                    continue
                }

                guard
                    let mapping = mappings.first(where: {
                        if var modifiers = $0.modifiers,
                            modifiers.contains(.shift)
                        {
                            modifiers.removeAll(where: { $0 == .shift })
                            return $0.key.uppercased() == input.utf8 && modifiers == input.modifiers
                        }
                        return $0.key.uppercased() == input.utf8.uppercased()
                            && ($0.modifiers == input.modifiers
                                || $0.modifiers == nil && input.modifiers.isEmpty)
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
                    UI.mode = .command
                    await CommandInput.shared.add("search ")
                    break
                case .openCommmandLine:
                    UI.mode = .command
                    break
                case .quitApplication:
                    UI.running = false  // I don't like it but it's ok for now
                }
            }
        }
    }

}
