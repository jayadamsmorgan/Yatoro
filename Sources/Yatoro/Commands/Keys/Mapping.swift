import SwiftNotCurses

public struct Mapping: Codable {

    public struct Action: Codable, Equatable {

        public enum Mode: Codable {
            case nrm, n
            case cmd, c
        }

        public var `do`: String
        public var mode: Mode

        public init(_ mode: Mode, _ action: String) {
            self.mode = mode
            self.do = action
        }

        public init() {
            self.do = ""
            self.mode = .nrm
        }

        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.do = try container.decodeIfPresent(String.self, forKey: .do) ?? ""
            self.mode = try container.decodeIfPresent(Mode.self, forKey: .mode) ?? .nrm
        }
    }

    public var key: String
    public var modifiers: [Input.Modifier]?
    public let action: Action

    public var remap: Bool = false

    public init(_ key: String, mod: [Input.Modifier]?, action: Action) {
        self.key = key
        self.modifiers = mod
        self.action = action
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.key = try container.decodeIfPresent(String.self, forKey: .key) ?? ""
        self.modifiers = try container.decodeIfPresent(Array<Input.Modifier>.self, forKey: .modifiers)
        self.action = try container.decodeIfPresent(Action.self, forKey: .action) ?? .init()
        self.remap = try container.decodeIfPresent(Bool.self, forKey: .remap) ?? false
    }
}

public extension Mapping {
    @MainActor static let defaultMappings: [Mapping] = [
        .init("p", mod: nil, action: .init(.cmd, "playPauseToggle<CR>")),
        .init("p", mod: [.shift], action: .init(.cmd, "play<CR>")),
        .init("p", mod: [.ctrl], action: .init(.cmd, "pause<CR>")),
        .init("c", mod: nil, action: .init(.cmd, "stop<CR>")),
        .init("x", mod: nil, action: .init(.cmd, "clearQueue<CR>")),
        .init("f", mod: nil, action: .init(.cmd, "playNext<CR>")),
        .init("f", mod: [.ctrl], action: .init(.cmd, "startSeekingForward<CR>")),
        .init("g", mod: nil, action: .init(.cmd, "stopSeeking<CR>")),
        .init("b", mod: nil, action: .init(.cmd, "playPrevious<CR>")),
        .init("b", mod: [.ctrl], action: .init(.cmd, "startSeekingBackward<CR>")),
        .init("r", mod: nil, action: .init(.cmd, "restartSong<CR>")),
        .init("s", mod: nil, action: .init(.cmd, "startSearching<CR>")),
        .init("s", mod: [.ctrl], action: .init(.cmd, "stationFromCurrentEntry<CR>")),
        .init("q", mod: nil, action: .init(.cmd, "quitApplication<CR>")),
        .init("e", mod: nil, action: .init(.cmd, "repeatMode<CR>")),
        .init("h", mod: nil, action: .init(.cmd, "shuffleMode<CR>")),
    ]
}
