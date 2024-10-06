import ArgumentParser

struct SearchCommand: AsyncParsableCommand {

    @Flag(exclusivity: .exclusive)
    var from: SearchType?

    @Argument
    var searchPhrase: [String] = []

    public func validate() throws {
        let searchType = from ?? .catalogSearchSongs

        switch searchType {
        case .catalogSearchSongs, .librarySearchSongs:
            if searchPhrase.isEmpty {
                throw ValidationError(
                    "Search phrase is required for catalog and library searches."
                )
            }
        case .recentlyPlayedSongs, .recommended:
            if !searchPhrase.isEmpty {
                throw ValidationError(
                    "Search phrase is not needed for recent and suggested searches."
                )
            }
        }
    }

}
