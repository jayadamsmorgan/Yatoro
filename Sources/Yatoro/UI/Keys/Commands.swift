import Logging
import MusadoraKit

public actor CommandInput {

    private var inputs: [Character]

    public static let shared = CommandInput()

    private var lastCommandOutput: String

    private var cursorPositionInWord: Int

    private init() {
        self.inputs = []
        self.lastCommandOutput = ""
        self.cursorPositionInWord = 0
    }

    private func deletePressed(_ newInput: Input) -> Bool {
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

    private func arrowKeysPressed(_ newInput: Input) -> Bool {
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

    public func add(_ newInput: Input) async {
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

    public func getCursorPosition() async -> Int {
        self.cursorPositionInWord
    }

    public func add(_ newCharacter: Character) async {
        inputs.append(newCharacter)
        cursorPositionInWord += 1
    }

    public func add(_ string: String) async {
        for char in string {
            self.inputs.append(char)
        }
        cursorPositionInWord += string.count
    }

    public func clear() async {
        self.inputs = []
        cursorPositionInWord = 0
    }

    public func get() async -> String {
        String(self.inputs)
    }

    public func setLastCommandOutput(_ newValue: String) async {
        self.lastCommandOutput = newValue
    }

    public func getLastCommandOutput() async -> String {
        self.lastCommandOutput
    }

}

public struct Command {
    public let name: String
    public let shortName: String?
    public var action: CommandAction?

    public init(name: String, short: String? = nil, action: CommandAction?) {
        self.name = name
        self.shortName = short
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
        .init(name: "stopSeeking", action: .stopSeeking),
        .init(name: "restartSong", action: .restartSong),
        .init(name: "quitApplication", short: "q", action: .quitApplication),
        .init(name: "search", action: .search),
        .init(name: "setSongTime", action: .setSongTime),
    ]

    public static func parseCommand() async {
        let commandString = await CommandInput.shared.get()
        let commandParts = commandString.split(separator: " ")
        guard let commandString = commandParts.first else {
            logger?.debug("Empty command entered")
            return
        }
        guard
            let command = defaultCommands.first(where: { cmd in
                if let short = cmd.shortName {
                    return short == commandString
                }
                return cmd.name == commandString
            })
        else {
            let msg = "Unknown command \"\(commandString)\""
            await CommandInput.shared.setLastCommandOutput(msg)
            logger?.debug(msg)
            return
        }
        let arguments = commandParts.dropFirst()
        guard let action = command.action else {
            let msg = "Command \"\(command.name)\" doesn't have any action."
            await CommandInput.shared.setLastCommandOutput(msg)
            logger?.debug(msg)
            return
        }
        switch action {

        case .playPauseToggle: await Player.shared.playPauseToggle()

        case .play: await Player.shared.play()

        case .pause: Player.shared.pause()

        case .stop: break

        case .clearQueue: await Player.shared.clearQueue()

        case .playNext: await Player.shared.playNext()

        case .startSeekingForward: Player.shared.player.beginSeekingForward()

        case .playPrevious: await Player.shared.playPrevious()

        case .startSeekingBackward: Player.shared.player.beginSeekingBackward()

        case .stopSeeking: Player.shared.player.endSeeking()

        case .restartSong: await Player.shared.restartSong()

        case .quitApplication: UI.running = false

        case .search:
            let phrase = String(arguments[1])
            await SearchManager.shared.newSearch(
                for: phrase,
                in: .catalogSearchSongs
            )

        case .setSongTime: Player.shared.player.playbackTime

        }
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
    case stopSeeking
    case restartSong
    case quitApplication
    case search
    case setSongTime
}
