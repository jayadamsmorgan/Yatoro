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
    case station

    public init?(argument: String) {
        switch argument {
        case "so", "song": self = .song
        case "al", "album": self = .album
        case "ar", "artist": self = .artist
        case "p", "pl", "playlist": self = .playlist
        case "st", "station": self = .station
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
    case some([String])
    case one(String)

    public init?(argument: String) {
        if argument == "all" || argument == "a" {
            self = .all
            return
        }
        let arguments = argument.split(separator: ",")
        guard arguments.count > 1 else {
            self = .one(argument)
            return
        }
        var strs: [String] = []
        for arg in arguments {
            let str = String(arg)
            if !strs.contains(str) {
                strs.append(str)
            }
        }
        self = .some(strs)
    }
}

extension MusicPlayer.RepeatMode: @retroactive ExpressibleByArgument {

    public init?(argument: String) {
        switch argument {
        case "off", "false", "none": self = .none
        case "a", "all": self = .all
        case "o", "one": self = .one
        default: return nil
        }
    }

}

extension MusicPlayer.ShuffleMode: @retroactive ExpressibleByArgument {

    public init?(argument: String) {
        switch argument {
        case "false", "off": self = .off
        case "true", "on": self = .songs
        default: return nil
        }
    }
}
