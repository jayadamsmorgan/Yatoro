import ArgumentParser
import MusicKit

extension SearchType: EnumerableFlag {

    public static func name(for value: SearchType) -> NameSpecification {
        switch value {
        case .recentlyPlayed:
            return [
                .customShort("r"),
                .long,
                .customLong("recent", withSingleDash: true),
            ]
        case .recommended:
            return [.customShort("s"), .long]
        case .catalogSearch:
            return [
                .customShort("c"),
                .long,
                .customLong("catalog", withSingleDash: true),
            ]
        case .librarySearch:
            return [
                .customShort("l"),
                .long,
                .customLong("library", withSingleDash: true),
            ]
        }
    }

}

public enum MusicItemType: Hashable, CaseIterable, Sendable, ExpressibleByArgument {

    case song
    case album
    case artist
    case playlist

    public init?(argument: String) {
        switch argument {
        case "s", "song": self = .song
        case "al", "album": self = .album
        case "ar", "artist": self = .artist
        case "p", "playlist": self = .playlist
        default: return nil
        }
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
