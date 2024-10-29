import SwiftNotCurses

public struct Mapping: Codable {

    public var key: String
    public var modifiers: [Input.Modifier]?
    public let action: CommandAction?

    public var remap: Bool = false

    public init(_ key: String, mod: [Input.Modifier]?, action: CommandAction?) {
        self.key = key
        self.modifiers = mod
        self.action = action
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.key = try container.decodeIfPresent(String.self, forKey: .key) ?? ""
        self.modifiers = try container.decodeIfPresent(Array<Input.Modifier>.self, forKey: .modifiers)
        self.action = try container.decodeIfPresent(CommandAction.self, forKey: .action)
        self.remap = try container.decodeIfPresent(Bool.self, forKey: .remap) ?? false
    }
}

public extension Mapping {
    @MainActor static let defaultMappings: [Mapping] = [
        .init("p", mod: nil, action: .playPauseToggle),
        .init("p", mod: [.shift], action: .play),
        .init("p", mod: [.ctrl], action: .pause),
        .init("c", mod: nil, action: .stop),
        .init("x", mod: nil, action: .clearQueue),
        .init("f", mod: nil, action: .playNext),
        .init("f", mod: [.ctrl], action: .startSeekingForward),
        .init("g", mod: nil, action: .stopSeeking),
        .init("b", mod: nil, action: .playPrevious),
        .init("b", mod: [.ctrl], action: .startSeekingBackward),
        .init("r", mod: nil, action: .restartSong),
        .init("s", mod: nil, action: .startSearching),
        .init(":", mod: [.shift], action: .openCommandLine),
        .init("s", mod: [.ctrl], action: .stationFromCurrentEntry),
        .init("q", mod: nil, action: .quitApplication),
    ]
}
