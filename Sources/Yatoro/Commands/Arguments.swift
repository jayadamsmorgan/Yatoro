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

    struct Index: CustomStringConvertible {

        var description: String {
            if let letter, let number {
                return "\(letter)\(number)"
            } else if let number {
                return "\(number)"
            } else if let letter {
                return "\(letter)"
            }
            return original
        }

        let number: Int?
        let letter: Character?

        let original: String

        init(from string: String) {
            self.original = string
            switch string.count {
            case 0:
                self.number = nil
                self.letter = nil
            case 1:
                self.number = Int(string)
                self.letter = nil
            default:
                self.number = Int(string.dropFirst())
                self.letter = string.lowercased().first
            }
        }

        func isValid() -> Bool {
            return !(number == nil && letter == nil)
        }
    }

    case all
    case some([Index])
    case one(Index)

    public init(argument: String) {

        // ALL
        if argument == "all" || argument == "a" {
            self = .all
            return
        }

        let arguments = argument.split(separator: ",")
        guard arguments.count > 1 else {
            // ONE
            let index = Index(from: argument)
            self = .one(index)
            return
        }

        // SOME
        var indices: [Index] = []
        for arg in arguments {
            guard arg.count > 0 else {
                continue
            }
            let index = Index(from: String(arg))
            indices.append(index)
        }
        self = .some(indices)
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
