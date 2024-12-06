import ArgumentParser

struct SearchCommand: AsyncParsableCommand {

    @Flag(exclusivity: .exclusive)
    var from: SearchType?

    @Option(name: .shortAndLong)
    var type: MusicItemType = .song

    @Argument(parsing: .captureForPassthrough)
    var searchPhrase: [String] = []

    public func validate() throws {
        let searchType = from ?? .catalogSearch

        if type == .station && from == .librarySearch {
            throw ValidationError("Can't search user library for stations")
        }

        switch searchType {
        case .catalogSearch, .librarySearch:
            if searchPhrase.isEmpty {
                throw ValidationError(
                    "Search phrase is required for catalog and library searches."
                )
            }
        default: break
        }
    }

    @MainActor
    static func execute(arguments: Array<String>) async {
        do {
            let command = try SearchCommand.parse(arguments)
            logger?.debug("New search command request: \(command)")
            var searchPhrase = ""
            for part in command.searchPhrase {
                searchPhrase.append("\(part) ")
            }
            if searchPhrase.count > 0 {
                searchPhrase.removeLast()
            }
            let limit = Config.shared.settings.searchItemLimit
            Task {
                await SearchManager.shared.newSearch(
                    for: searchPhrase,
                    itemType: command.type,
                    in: command.from ?? .catalogSearch,
                    inPlace: true,
                    limit: limit
                )
            }
        } catch {
            if let error = error as? CommandError {
                switch error.parserError {
                case .userValidationError(let validationError):
                    let validationError = validationError as! ValidationError
                    let msg = validationError.message
                    logger?.debug("CommandParser: search: \(msg)")
                    await CommandInput.shared.setLastCommandOutput(msg)
                default:
                    let msg = "Error: wrong arguments"
                    logger?.debug("CommandParser: search: \(msg)")
                    await CommandInput.shared.setLastCommandOutput(msg)
                }
            }
        }
    }

}
