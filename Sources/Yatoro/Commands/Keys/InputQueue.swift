import Foundation
import Logging
import SwiftNotCurses
import notcurses

@MainActor
public class InputQueue {

    public var mappings: [Mapping]

    private var queue: BlockingQueue<Input>

    private var commandHistory: [String]
    private var commandHistoryIndex: Int?

    public var completionCommands: [String]?
    public var currentCompletionCommandIndex: Int?

    public func add(_ newInput: Input) {
        Task {
            await queue.enqueue(newInput)
        }
    }

    public init(mappings: [Mapping], commandHistory: [String] = []) {
        self.mappings = mappings
        self.queue = .init()
        self.commandHistory = commandHistory
    }

    public func start() async {
        Task {
            while (true) {
                let input = await self.queue.dequeue()

                guard UI.mode == .normal else {
                    // CMD mode
                    await CommandInput.shared.setLastCommandOutput("")
                    let commandString = await CommandInput.shared.get()

                    switch input.id {

                    case 27:  // Escape
                        if completionCommands != nil {

                        }
                        UI.mode = .normal
                        await CommandInput.shared.clear()

                    case 1115121:  // Enter
                        UI.mode = .normal
                        await Command.parseCommand(commandString)
                        await CommandInput.shared.clear()

                    case 1115008:  // Backspace
                        if commandString.isEmpty {
                            UI.mode = .normal
                        }
                        await CommandInput.shared.add(input)

                    case 1115002:  // Arrow up
                        break

                    case 1115004:  // Arrow down
                        break

                    case 9:  // Tab
                        if completionCommands == nil {
                            // Completions are not active, activate them
                            populateCompletionCommands()
                            break
                        }
                        if input.modifiers.contains(.shift) {
                            // Shift + Tab
                            break
                        }
                    // Tab

                    default:
                        // Any other key
                        await CommandInput.shared.add(input)

                    }

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
                        }
                    case .special(let char):
                        if let input = parseToken(char) {
                            add(input)
                        } else {
                            logger?.error("InputQueue: Unable to parse token \(char)")
                        }
                    }
                }

            }
        }
    }

    private func populateCompletionCommands(_ command: String) {
        var completionCommands: [String] = Command.defaultCommands.map({ $0.name })
        completionCommands.removeAll(where: { !$0.hasPrefix(command) })
        self.completionCommands = commandNames
        self.currentCompletionCommandIndex = 0
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

        if modifiers.contains(.shift) {
            modifiers.removeAll(where: { $0 == .shift })
            if keyChar != nil {
                keyChar = Character(keyChar!.uppercased())
            }
        }
        if let keyCode = keyCode {
            return Input(id: keyCode, modifiers: modifiers)
        } else if let keyChar = keyChar {
            return Input(utf8: String(keyChar), modifiers: modifiers)
        }

        return nil
    }
}
