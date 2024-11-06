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

}
