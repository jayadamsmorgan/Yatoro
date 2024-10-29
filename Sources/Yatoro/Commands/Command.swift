import ArgumentParser
import Logging
import MusicKit

public struct Command: Sendable {
    public let name: String
    public let shortName: String?
    public var action: CommandAction?
    public let arguments: [Command]

    public init(
        name: String,
        short: String? = nil,
        action: CommandAction?,
        arguments: [Command] = []
    ) {
        self.name = name
        self.shortName = short
        self.action = action
        self.arguments = arguments
    }

    public static let defaultCommands: [Command] = [
        .init(name: "addToQueue", short: "a", action: .addToQueue),
        .init(name: "play", short: "pl", action: .play),
        .init(name: "playPauseToggle", short: "pp", action: .playPauseToggle),
        .init(name: "pause", short: "pa", action: .pause),
        .init(name: "stop", short: "s", action: .stop),
        .init(name: "clearQueue", short: "c", action: .clearQueue),
        .init(name: "playNext", short: "pn", action: .playNext),
        .init(name: "startSeekingForward", short: "sf", action: .startSeekingForward),
        .init(name: "playPrevious", short: "b", action: .playPrevious),
        .init(name: "startSeekingBackward", short: "sb", action: .startSeekingBackward),
        .init(name: "stopSeeking", short: "ss", action: .stopSeeking),
        .init(name: "restartSong", short: "r", action: .restartSong),
        .init(name: "quitApplication", short: "q", action: .quitApplication),
        .init(name: "search", short: "/", action: .search),
        .init(name: "setSongTime", short: "set", action: .setSongTime),
        .init(name: "stationFromCurrentEntry", short: "sce", action: .stationFromCurrentEntry),
    ]

    @MainActor
    public static func parseCommand() async {
        let commandString = await CommandInput.shared.get()
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
        case .addToQueue:
            do {
                let command = try AddToQueueCommand.parse(arguments)
                logger?.debug("New add to queue command request: \(command)")
                guard
                    let searchResult = SearchManager.shared.lastSearchResults[command.from]
                else {
                    let msg = "No last \(command.from) search result"
                    logger?.debug(msg)
                    await CommandInput.shared.setLastCommandOutput(msg)
                    return
                }

                let result = searchResult.result

                var items: MusicItemCollection<Song>

                switch command.item {

                case .all: items = result as! MusicItemCollection<Song>

                case .some(let ints):
                    var itemsArr: [any MusicItem] = []
                    for index in ints {
                        if let item = result.item(at: index) {
                            itemsArr.append(item)
                        }
                    }
                    items = .init(itemsArr as! [Song])

                case .one(let int):
                    guard let item = result.item(at: int) else {
                        return
                    }
                    guard let item = item as? Song else {  // TODO: ???
                        return
                    }
                    await Player.shared.addItemsToQueue(
                        items: [item],
                        at: command.to
                    )
                    return
                }

                await Player.shared.addItemsToQueue(
                    items: items,
                    at: command.to
                )

            } catch {
                let msg = error.localizedDescription
                logger?.debug(msg)
                await CommandInput.shared.setLastCommandOutput(msg)
            }

        case .playPauseToggle: await Player.shared.playPauseToggle()

        case .play: await Player.shared.play()

        case .pause: await Player.shared.pause()

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
            do {
                let command = try SearchCommand.parse(arguments)
                logger?.debug("New search command request: \(command)")
                var searchPhrase = ""
                for part in command.searchPhrase {
                    searchPhrase.append("\(part) ")
                }
                Task {
                    await SearchManager.shared.newSearch(
                        for: searchPhrase,
                        in: command.from ?? .catalogSearchSongs
                    )
                }
            } catch {
                let msg = error.localizedDescription
                logger?.debug(msg)
                await CommandInput.shared.setLastCommandOutput(msg)
            }

        case .setSongTime:
            do {
                let command = try SetSongTimeCommand.parse(arguments)
                logger?.debug("New set song time command request: \(command)")

                let error = ValidationError("Unknown time format")

                guard command.time.contains(":") else {
                    guard let seconds = Int(command.time) else {
                        throw error
                    }

                    await Player.shared.setTime(
                        seconds: seconds,
                        relative: command.relative
                    )
                    return
                }

                let split = command.time.split(separator: ":")

                switch split.count {
                case 2:  // MM:SS
                    guard let minutesPart = Int(split[0]) else {
                        throw error
                    }
                    guard let secondsPart = Int(split[1]) else {
                        throw error
                    }
                    let seconds = minutesPart * 60 + secondsPart
                    await Player.shared.setTime(
                        seconds: seconds,
                        relative: command.relative
                    )

                case 3:  // HH:MM:SS
                    guard let hoursPart = Int(split[0]) else {
                        throw error
                    }
                    guard let minutesPart = Int(split[1]) else {
                        throw error
                    }
                    guard let secondsPart = Int(split[2]) else {
                        throw error
                    }
                    let seconds =
                        hoursPart * 60 * 60 + minutesPart * 60 + secondsPart
                    await Player.shared.setTime(
                        seconds: seconds,
                        relative: command.relative
                    )

                default:
                    throw error
                }

            } catch {
                let msg = error.localizedDescription
                logger?.debug(msg)
                await CommandInput.shared.setLastCommandOutput(msg)
            }

        case .stationFromCurrentEntry:
            await Player.shared.playStationFromCurrentSong()

        case .openCommandLine: break

        case .startSearching: break

        }
        return
    }
}

public enum CommandAction: Sendable, Codable {
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
    case openCommandLine
    case startSearching
    case stopSeeking
    case restartSong
    case quitApplication
    case search
    case setSongTime
    case stationFromCurrentEntry
}
