import Logging
import MusadoraKit

public struct CommandInput {

    private var inputs: [Character]

    public static var shared = CommandInput()

    public var lastCommandOutput: String

    private var cursorPositionInWord: Int

    private init() {
        self.inputs = []
        self.lastCommandOutput = ""
        self.cursorPositionInWord = 0
    }

    private mutating func deletePressed(_ newInput: Input) -> Bool {
        if newInput.id == 1115008 {
            // DELETE pressed
            if !inputs.isEmpty {
                self.cursorPositionInWord -= 1
                inputs.remove(at: cursorPositionInWord)
            }
            return true
        }
        return false
    }

    private mutating func arrowKeysPressed(_ newInput: Input) -> Bool {
        switch newInput.id {
        case 1115005:
            // left
            if cursorPositionInWord > 0 {
                cursorPositionInWord -= 1
            }
            return true
        case 1115003:
            // right
            if cursorPositionInWord < inputs.count {
                cursorPositionInWord += 1
            }
            return true
        default:
            return false
        }
    }

    public mutating func add(_ newInput: Input) {
        guard !deletePressed(newInput) else {
            return
        }
        guard !arrowKeysPressed(newInput) else {
            return
        }
        guard !newInput.utf8.isEmpty else {
            return
        }
        inputs.insert(Character(newInput.utf8), at: cursorPositionInWord)
        cursorPositionInWord += 1
    }

    public func getCursorPosition() -> Int {
        self.cursorPositionInWord
    }

    public mutating func add(_ newCharacter: Character) {
        inputs.append(newCharacter)
        cursorPositionInWord += 1
    }

    public mutating func add(_ string: String) {
        for char in string {
            self.inputs.append(char)
        }
        cursorPositionInWord += string.count
    }

    public mutating func clear() {
        self.inputs = []
        cursorPositionInWord = 0
    }

    public func get() -> String {
        String(self.inputs)
    }

}

public struct Command {
    public let name: String
    public var action: CommandAction?

    public init(name: String, action: CommandAction?) {
        self.name = name
        self.action = action
    }

    public static let defaultCommands: [Command] = [
        .init(name: "play", action: .play),
        .init(name: "playPauseToggle", action: .playPauseToggle),
        .init(name: "play", action: .play),
        .init(name: "pause", action: .pause),
        .init(name: "stop", action: .stop),
        .init(name: "clearQueue", action: .clearQueue),
        .init(name: "playNext", action: .playNext),
        .init(name: "startSeekingForward", action: .startSeekingForward),
        .init(name: "playPrevious", action: .playPrevious),
        .init(name: "startSeekingBackward", action: .startSeekingBackward),
        .init(name: "restartSong", action: .restartSong),
        .init(name: "openCommmandLine", action: .openCommmandLine),
        .init(name: "quitApplication", action: .quitApplication),
        .init(name: "search", action: nil),
        .init(name: "setSongTime", action: nil),
    ]

    public static func parseCommand(logger: Logger?) {
        let commandString = CommandInput.shared.get()
        let commandParts = commandString.split(separator: " ")
        guard let commandString = commandParts.first else {
            logger?.debug("Empty command entered")
            return
        }
        guard
            let command = defaultCommands.first(where: { cmd in
                cmd.name == commandString
            })
        else {
            let msg = "Unknown command \"\(commandString)\""
            CommandInput.shared.lastCommandOutput = msg
            logger?.debug(msg)
            return
        }
        let arguments = commandParts.dropFirst()
        return
    }
}

public enum CommandAction {
    case playPauseToggle
    case play
    case pause
    case stop
    case clearQueue
    case playNext
    case startSeekingForward
    case playPrevious
    case startSeekingBackward
    case restartSong
    case openCommmandLine
    case quitApplication
    case search(String, MCatalogSearchType?)
    case setSongTime(String)
}
