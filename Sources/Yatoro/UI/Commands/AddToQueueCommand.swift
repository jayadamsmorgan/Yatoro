import ArgumentParser
import MusicKit

extension SearchType: ExpressibleByArgument {

    public init?(argument: String) {
        switch argument {
        case "recent", "r": self = .recentlyPlayedSongs
        case "suggested", "s": self = .recommended
        case "catalog", "c": self = .catalogSearchSongs
        case "library", "l": self = .librarySearchSongs
        default: return nil
        }
    }
}

enum SearchItemIndex: ExpressibleByArgument {
    case all
    case some([Int])
    case one(Int)

    public init?(argument: String) {
        if argument == "all" || argument == "a" {
            self = .all
            return
        }
        let arguments = argument.split(separator: ",")
        guard arguments.count > 1 else {
            self = .one(Int(argument) ?? 0)
            return
        }
        var ints: [Int] = []
        for arg in arguments {
            let int = Int(arg) ?? 0
            if !ints.contains(int) {
                ints.append(int)
            }
        }
        self = .some(ints)
    }
}

extension ApplicationMusicPlayer.Queue.EntryInsertionPosition:
    @retroactive ExpressibleByArgument
{

    public init?(argument: String) {
        switch argument {
        case "tail", "end", "later", "t", "e", "l": self = .tail
        case "next", "afterCurrentEntry", "n", "a": self = .afterCurrentEntry
        default: return nil
        }
    }

}

struct AddToQueueCommand: AsyncParsableCommand {

    @Argument
    var from: SearchType

    @Argument
    var item: SearchItemIndex

    @Argument
    var to: ApplicationMusicPlayer.Queue.EntryInsertionPosition

}
