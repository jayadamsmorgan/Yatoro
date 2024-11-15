import ArgumentParser
import MusicKit

struct AddToQueueCommand: AsyncParsableCommand {

    @Argument
    var item: SearchItemIndex

    @Argument
    var to: ApplicationMusicPlayer.Queue.EntryInsertionPosition = .tail

    @MainActor
    static func execute(arguments: Array<String>) async {
        do {
            let command = try AddToQueueCommand.parse(arguments)
            logger?.debug("New add to queue command request: \(command)")
            guard
                let lastResult = SearchManager.shared.lastSearchResult
            else {
                let msg = "Error: No current search result"
                logger?.debug(msg)
                await CommandInput.shared.setLastCommandOutput(msg)
                return
            }

            guard lastResult.itemType != .artist else {
                let msg = "Error: Can't add artist to queue"
                logger?.debug(msg)
                await CommandInput.shared.setLastCommandOutput(msg)
                return
            }

            let result = lastResult.result

            switch command.item {

            case .all:
                switch result {

                case let result as MusicItemCollection<Song>:
                    await Player.shared.addItemsToQueue(items: result, at: command.to)

                case let result as MusicItemCollection<Album>:
                    await Player.shared.addItemsToQueue(items: result, at: command.to)

                case let result as MusicItemCollection<RecentlyPlayedMusicItem>:
                    await Player.shared.addItemsToQueue(items: result, at: command.to)

                case let result as MusicItemCollection<Playlist>:
                    await Player.shared.addItemsToQueue(items: result, at: command.to)

                case let result as MusicItemCollection<Station>:
                    await Player.shared.addItemsToQueue(items: result, at: command.to)

                default: break
                }

            case .some(let indices):
                switch result {

                case let result as MusicItemCollection<Song>:
                    var songs: [Song] = []
                    for index in indices {
                        if let item = result.item(at: index) {
                            songs.append(item)
                        }
                    }
                    await Player.shared.addItemsToQueue(items: .init(songs), at: command.to)

                case let result as MusicItemCollection<Album>:
                    var albums: [Album] = []
                    for index in indices {
                        if let item = result.item(at: index) {
                            albums.append(item)
                        }
                    }
                    await Player.shared.addItemsToQueue(items: .init(albums), at: command.to)

                case let result as MusicItemCollection<RecentlyPlayedMusicItem>:
                    var items: [RecentlyPlayedMusicItem] = []
                    for index in indices {
                        if let item = result.item(at: index) {
                            items.append(item)
                        }
                    }
                    await Player.shared.addItemsToQueue(items: .init(items), at: command.to)

                case let result as MusicItemCollection<Playlist>:
                    var items: [Playlist] = []
                    for index in indices {
                        if let item = result.item(at: index) {
                            items.append(item)
                        }
                    }
                    await Player.shared.addItemsToQueue(items: .init(items), at: command.to)

                case let result as MusicItemCollection<Station>:
                    var items: [Station] = []
                    for index in indices {
                        if let item = result.item(at: index) {
                            items.append(item)
                        }
                    }
                    await Player.shared.addItemsToQueue(items: .init(items), at: command.to)

                default: break

                }

            case .one(let int):
                guard let item = result.item(at: int) else {
                    return
                }
                switch item {
                case let item as Song:
                    await Player.shared.addItemsToQueue(items: [item], at: command.to)
                case let item as Album:
                    await Player.shared.addItemsToQueue(items: [item], at: command.to)
                case let item as RecentlyPlayedMusicItem:
                    await Player.shared.addItemsToQueue(items: [item], at: command.to)
                case let item as Playlist:
                    await Player.shared.addItemsToQueue(items: [item], at: command.to)
                case let item as Station:
                    await Player.shared.addItemsToQueue(items: [item], at: command.to)
                default: break
                }
            }

        } catch {
            if let error = error as? CommandError {
                switch error.parserError {
                case .userValidationError(let validationError):
                    let validationError = validationError as! ValidationError
                    let msg = validationError.message
                    logger?.debug("CommandParser: addToQueue: \(msg)")
                    await CommandInput.shared.setLastCommandOutput(msg)
                default:
                    let msg = "Error parsing addToQueue command, check arguments"
                    logger?.debug("CommandParser: addToQueue: \(msg)")
                    await CommandInput.shared.setLastCommandOutput(msg)
                }
            }
        }
    }
}
