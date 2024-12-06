import ArgumentParser
import Logging
import MusicKit

public struct Command: Sendable {
    public let name: String
    public let shortName: String?
    public var action: CommandAction?

    public init(
        name: String,
        short: String? = nil,
        action: CommandAction?
    ) {
        self.name = name
        self.shortName = short
        self.action = action
    }

    public static let defaultCommands: [Command] = [
        .init(name: "addToQueue", short: "a", action: .addToQueue),
        .init(name: "play", short: "pl", action: .play),
        .init(name: "playPauseToggle", short: "pp", action: .playPauseToggle),
        .init(name: "pause", short: "pa", action: .pause),
        .init(name: "stop", short: "s", action: .stop),
        .init(name: "clearQueue", short: "cq", action: .clearQueue),
        .init(name: "playNext", short: "pn", action: .playNext),
        .init(name: "startSeekingForward", short: "sf", action: .startSeekingForward),
        .init(name: "playPrevious", short: "b", action: .playPrevious),
        .init(name: "startSeekingBackward", short: "sb", action: .startSeekingBackward),
        .init(name: "stopSeeking", short: "ss", action: .stopSeeking),
        .init(name: "restartSong", short: "r", action: .restartSong),
        .init(name: "quitApplication", short: "q", action: .quitApplication),
        .init(name: "search", short: "/", action: .search),
        .init(name: "setSongTime", short: "time", action: .setSongTime),
        .init(name: "stationFromCurrentEntry", short: "sce", action: .stationFromCurrentEntry),
        .init(name: "shuffleMode", short: "shuffle", action: .shuffleMode),
        .init(name: "repeatMode", short: "repeat", action: .repeatMode),
        .init(name: "reloadConfig", short: "upd", action: .reloadConfig),
        .init(name: "open", short: "o", action: .open),
        .init(name: "close", short: "c", action: .close),
        .init(name: "closeAll", short: "ca", action: .closeAll),
    ]

    @MainActor
    public static func parseCommand(_ commandString: String) async {
        let commandParts = Array(commandString.split(separator: " "))
        guard let commandString = commandParts.first else {
            logger?.debug("Empty command entered")
            return
        }
        guard
            let command = defaultCommands.first(where: { cmd in
                if let short = cmd.shortName {
                    return short == commandString || cmd.name == commandString
                }
                return cmd.name == commandString
            })
        else {
            let msg = "Unknown command \"\(commandString)\""
            await CommandInput.shared.setLastCommandOutput(msg)
            logger?.debug(msg)
            return
        }
        let arguments = Array(commandParts.dropFirst().map(String.init))
        guard let action = command.action else {
            let msg = "Command \"\(command.name)\" doesn't have any action."
            await CommandInput.shared.setLastCommandOutput(msg)
            logger?.debug(msg)
            return
        }
        switch action {

        case .addToQueue: await AddToQueueCommand.execute(arguments: arguments)

        case .playPauseToggle: await Player.shared.playPauseToggle()

        case .play: await Player.shared.play()

        case .pause: await Player.shared.pause()

        case .stop: Player.shared.player.stop()

        case .clearQueue: await Player.shared.clearQueue()

        case .playNext: await Player.shared.playNext()

        case .startSeekingForward: Player.shared.player.beginSeekingForward()

        case .playPrevious: await Player.shared.playPrevious()

        case .startSeekingBackward: Player.shared.player.beginSeekingBackward()

        case .stopSeeking: Player.shared.player.endSeeking()

        case .restartSong: await Player.shared.restartSong()

        case .quitApplication: UI.running = false

        case .search: await SearchCommand.execute(arguments: arguments)

        case .setSongTime: await SetSongTimeCommand.execute(arguments: arguments)

        case .stationFromCurrentEntry: await Player.shared.playStationFromCurrentSong()

        case .repeatMode: await RepeatModeCommand.execute(arguments: arguments)

        case .shuffleMode: await ShuffleModeCommand.execute(arguments: arguments)

        case .reloadConfig:
            Config.load(logLevel: logger?.logLevel)
            UIPageManager.configReload = true

        case .open: await OpenCommand.execute(arguments: arguments)

        case .close:
            SearchManager.shared.lastSearchResult = nil

        case .closeAll: break

        }
        return
    }
}

public enum CommandAction: String, Sendable, Codable {
    case addToQueue
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
    case stationFromCurrentEntry
    case repeatMode
    case shuffleMode
    case reloadConfig
    case open
    case close
    case closeAll
}
