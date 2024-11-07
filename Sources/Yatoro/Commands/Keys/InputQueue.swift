import Foundation
import Logging
import SwiftNotCurses
import notcurses

@MainActor
public class InputQueue {

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
                    let commandString = await CommandInput.shared.get()
                    guard input.id != 1115121 else {
                        // Enter pressed
                        UI.mode = .normal
                        await Command.parseCommand(commandString)
                        await CommandInput.shared.clear()
                        continue
                    }
                    if input.id == 1115008 && commandString.isEmpty {
                        // Backspace pressed when the command input is empty
                        UI.mode = .normal
                        continue
                    }
                    await CommandInput.shared.add(input)
                    continue
                }

                if input.utf8 == ":" && input.modifiers.isEmpty {
                    UI.mode = .command
                    continue
                }

                let mapping = mappings.first(where: { mapping in
                    let id: UInt32
                    switch mapping.key.uppercased() {
                    case "ESC": id = 27
                    case "ENTER", "RETURN": id = 1115121
                    case "TAB": id = 9
                    case "SPACE": id = 32
                    case "ARROW_LEFT": id = 1115005
                    case "ARROW_RIGHT": id = 1115003
                    case "ARROW_UP": id = 1115002
                    case "ARROW_DOWN": id = 1115004
                    case "DELETE": id = 1115008
                    case "BACKSPACE": id = 1115008  // TODO: fix
                    default:
                        if let mods = mapping.modifiers {
                            return input.modifiers.elementsEqual(mods) && input.utf8 == mapping.key
                        } else {
                            return input.utf8 == mapping.key && input.modifiers.isEmpty
                        }
                    }
                    if let mods = mapping.modifiers {
                        return input.modifiers.elementsEqual(mods) && input.id == id
                    } else {
                        return input.id == id && input.modifiers.isEmpty
                    }
                })

                guard let mapping else {
                    continue
                }

                switch mapping.action.mode {
                case .nrm, .n: break

                case .cmd, .c: break
                }

            }
        }
    }

}
