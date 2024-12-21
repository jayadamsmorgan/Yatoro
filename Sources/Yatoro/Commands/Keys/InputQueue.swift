import Foundation
import Logging
import SwiftNotCurses
import notcurses

@MainActor
public class InputQueue {

    public static let shared: InputQueue = .init()

    public var mappings: [Mapping] = []

    private var mappingPlaying: Int = 0

    private let queue: BlockingQueue<Input> = .init()

    private var commandHistoryActive: Bool {
        commandHistoryIndex != nil
    }
    private var fullCommandHistory: [String] = []
    private var currentCommandHistory: [String] = []
    private var commandHistoryIndex: Int?

    public var commandCompletionsActive: Bool {
        currentCompletionCommandIndex != nil
    }
    public var completionCommands: [String] = []
    public var currentCompletionCommandIndex: Int?

    public func add(_ newInput: Input) {
        Task {
            await queue.enqueue(newInput)
        }
    }

    public func start() async {
        Task {
            while (true) {
                let input = await self.queue.dequeue()

                if mappingPlaying > 0 {
                    mappingPlaying -= 1
                }

                guard UI.mode == .normal else {
                    // CMD mode
                    await CommandInput.shared.setLastCommandOutput("")
                    let commandString = await CommandInput.shared.get()

                    switch input.id {

                    case 27:  // Escape
                        clearCurrentHistory()
                        closeCompletionCommands()
                        UI.mode = .normal
                        await CommandInput.shared.clear()

                    case 1115121:  // Enter
                        if commandCompletionsActive {
                            await CommandInput.shared.clear()
                            await CommandInput.shared.add(completionCommands[currentCompletionCommandIndex!])
                            closeCompletionCommands()
                            break
                        }

                        if mappingPlaying == 0 {
                            fullCommandHistory.append(commandString)
                        }
                        clearCurrentHistory()

                        UI.mode = .normal

                        await Command.parseCommand(commandString)
                        await CommandInput.shared.clear()

                    case 1115008:  // Backspace
                        closeCompletionCommands()
                        if commandString.isEmpty {
                            UI.mode = .normal
                        }
                        await CommandInput.shared.add(input)

                    case 1115003:  // Arrow right
                        if commandCompletionsActive {
                            await nextCompletionCommand(commandString)
                            break
                        }
                        await CommandInput.shared.add(input)

                    case 1115005:  // Arrow left
                        if commandCompletionsActive {
                            await previousCompletionCommand(commandString)
                            break
                        }
                        await CommandInput.shared.add(input)

                    case 1115002:  // Arrow up
                        if commandCompletionsActive {
                            closeCompletionCommands()
                            break
                        }
                        await previousHistoryCommand(commandString)

                    case 1115004:  // Arrow down
                        if commandCompletionsActive {
                            closeCompletionCommands()
                            break
                        }
                        await nextHistoryCommand()

                    case 9:  // Tab
                        if input.modifiers.contains(.shift) {
                            // Shift + Tab
                            await previousCompletionCommand(commandString)
                            break
                        }
                        // Tab
                        await nextCompletionCommand(commandString)

                    default:  // Any other key
                        clearCurrentHistory()
                        closeCompletionCommands()
                        await CommandInput.shared.add(input)

                    }

                    continue
                }

                // This is what happens in all terminals except for iTerm2
                if input.utf8 == ":" && input.modifiers.isEmpty {
                    UI.mode = .command
                    continue
                }

                // This is what happens in iTerm2
                if input.utf8 == ";" && input.modifiers == [.shift] {
                    UI.mode = .command
                    continue
                }

                let mapping = mappings.first(where: { mapping in
                    let id: UInt32
                    switch mapping.key.uppercased() {
                    case "ESC": id = 27
                    case "ENTER", "RETURN", "CR": id = 1115121
                    case "TAB": id = 9
                    case "SPACE": id = 32
                    case "ARROW_LEFT": id = 1115005
                    case "ARROW_RIGHT": id = 1115003
                    case "ARROW_UP": id = 1115002
                    case "ARROW_DOWN": id = 1115004
                    case "DELETE", "BACKSPACE": id = 1115008
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

                let tokens = tokenizeAction(mapping.action)

                for token in tokens {
                    switch token {
                    case .literal(let string):
                        for char in string {
                            let input = Input(utf8: String(char))
                            add(input)
                            mappingPlaying += 1
                        }
                    case .special(let char):
                        if let input = parseToken(char) {
                            add(input)
                            mappingPlaying += 1
                        } else {
                            logger?.error("InputQueue: Unable to parse token \(char)")
                        }
                    }
                }
                mappingPlaying += 1

            }
        }
    }

    private func previousHistoryCommand(_ command: String) async {
        guard let commandHistoryIndex else {
            await populateHistoryCommands(command)
            return
        }
        guard commandHistoryIndex > currentCommandHistory.startIndex else {
            return
        }
        self.commandHistoryIndex = commandHistoryIndex - 1
        await CommandInput.shared.clear()
        await CommandInput.shared.add(currentCommandHistory[self.commandHistoryIndex!])
    }

    private func nextHistoryCommand() async {
        if let commandHistoryIndex,
            commandHistoryIndex < currentCommandHistory.endIndex - 1
        {
            self.commandHistoryIndex = commandHistoryIndex + 1
            await CommandInput.shared.clear()
            await CommandInput.shared.add(currentCommandHistory[self.commandHistoryIndex!])
        }
    }

    private func populateHistoryCommands(_ command: String) async {
        currentCommandHistory = fullCommandHistory
        currentCommandHistory.removeAll(where: { !$0.hasPrefix(command) })
        if !currentCommandHistory.isEmpty {
            commandHistoryIndex = currentCommandHistory.count - 1
            currentCommandHistory.append(command)
            await CommandInput.shared.clear()
            await CommandInput.shared.add(currentCommandHistory[commandHistoryIndex!])
        }
    }

    private func clearCurrentHistory() {
        self.currentCommandHistory = []
        commandHistoryIndex = nil
    }

    private func previousCompletionCommand(_ command: String) async {
        if let currentCompletionCommandIndex {
            if currentCompletionCommandIndex > completionCommands.startIndex {
                self.currentCompletionCommandIndex = currentCompletionCommandIndex - 1
            } else {
                self.currentCompletionCommandIndex = completionCommands.endIndex - 1
            }
            await CommandInput.shared.clear()
            await CommandInput.shared.add(completionCommands[self.currentCompletionCommandIndex!])
        } else {
            await populateCompletionCommands(command)
        }
    }

    private func nextCompletionCommand(_ command: String) async {
        if let currentCompletionCommandIndex {
            if currentCompletionCommandIndex < completionCommands.endIndex - 1 {
                self.currentCompletionCommandIndex = currentCompletionCommandIndex + 1
            } else {
                self.currentCompletionCommandIndex = completionCommands.startIndex
            }
            await CommandInput.shared.clear()
            await CommandInput.shared.add(completionCommands[self.currentCompletionCommandIndex!])
        } else {
            await populateCompletionCommands(command)
        }
    }

    private func populateCompletionCommands(_ command: String) async {
        completionCommands = Command.defaultCommands.map({ $0.name })
        completionCommands.removeAll(where: { !$0.hasPrefix(command) || $0.isEmpty })
        completionCommands.sort()
        if !completionCommands.isEmpty {
            await CommandInput.shared.clear()
            await CommandInput.shared.add(completionCommands.first!)
            if completionCommands.count == 1 {
                closeCompletionCommands()
            } else {
                self.currentCompletionCommandIndex = 0
            }
        }
    }

    private func closeCompletionCommands() {
        self.completionCommands = []
        self.currentCompletionCommandIndex = nil
    }

    private enum ActionToken {
        case literal(String)
        case special(String)
    }

    private func tokenizeAction(_ action: String) -> [ActionToken] {
        var tokens: [ActionToken] = []
        var currentLiteral = ""
        var index = action.startIndex
        let end = action.endIndex
        var isEscaped = false
        var isInToken = false
        var currentToken = ""

        while index < end {
            let char = action[index]
            if isEscaped {
                if isInToken {
                    currentToken.append(char)
                } else {
                    currentLiteral.append(char)
                }
                isEscaped = false
            } else {
                switch char {
                case "\\":
                    // Next char is escaped
                    isEscaped = true
                case "<":
                    if isInToken {
                        // Nested
                        currentToken.append(char)
                    } else {
                        // Start of speacial
                        if !currentLiteral.isEmpty {
                            tokens.append(.literal(currentLiteral))
                            currentLiteral = ""
                        }
                        isInToken = true
                        currentToken = ""
                    }
                case ">":
                    if isInToken {
                        // End of special
                        tokens.append(.special(currentToken))
                        isInToken = false
                    } else {
                        // Unmatched, treat as literal
                        currentLiteral.append(char)
                    }
                default:
                    if isInToken {
                        currentToken.append(char)
                    } else {
                        currentLiteral.append(char)
                    }
                }
            }
            index = action.index(after: index)
        }
        // Remaining
        if !currentLiteral.isEmpty {
            tokens.append(.literal(currentLiteral))
        }

        if isInToken {
            // Unmatched, treat as literal
            tokens.append(.literal("<" + currentToken))
        }

        return tokens
    }

    private var tokenActions: [String: UInt32] {
        return [
            "CR": 1115121,
            "ESC": 27,
            "TAB": 9,
            "SPACE": 32,
        ]
    }

    private func parseToken(_ token: String) -> Input? {
        var modifiers: [Input.Modifier] = []
        var keyChar: Character?
        var keyCode: UInt32?

        let components = token.components(separatedBy: "-")
        for component in components {
            if let modifier = Input.Modifier.init(rawValue: component.lowercased()) {
                modifiers.append(modifier)
            } else if let code = tokenActions[component.uppercased()] {
                keyCode = code
            } else if component.count == 1 {
                keyChar = component.first
            }
        }

        if let keyCode = keyCode {
            return Input(id: keyCode, modifiers: modifiers)
        } else if let keyChar = keyChar {
            var keyStr = String(keyChar)
            if modifiers.contains(.shift) {
                modifiers.removeAll(where: { $0 == .shift })
                keyStr = keyStr.uppercased()
            }
            return Input(utf8: keyStr, modifiers: modifiers)
        }

        return nil
    }
}
