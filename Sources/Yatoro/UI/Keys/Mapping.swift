public struct Mapping: Decodable {

    public var utf8: String
    public var modifiers: [Input.Modifier]?
    public let action: Action

    public init(_ utf8: String, mod: [Input.Modifier]?, action: Action) {
        self.utf8 = utf8
        self.modifiers = mod
        self.action = action
    }

    public enum Action: String, Decodable {
        case playPauseToggle
        case play
        case pause
        case stop
        case clearQueue
        case playNext
        case startSeekingForward
        case playPrevious
        case startSeekingBackward
        case restartSong
        case startSearching
        case openCommmandLine
        case quitApplication
    }
}

public extension Mapping {
    static let defaultMappings: [Mapping] = [
        .init("p", mod: nil, action: .playPauseToggle),
        .init("P", mod: [.shift], action: .play),
        .init("p", mod: [.ctrl], action: .pause),
        .init("c", mod: [.ctrl], action: .stop),
        .init("C", mod: [.shift], action: .clearQueue),
        .init("f", mod: nil, action: .playNext),
        .init("F", mod: [.shift], action: .startSeekingForward),
        .init("b", mod: nil, action: .playPrevious),
        .init("B", mod: [.shift], action: .startSeekingBackward),
        .init("r", mod: nil, action: .restartSong),
        .init("S", mod: [.shift], action: .startSearching),
        .init(":", mod: [.shift], action: .openCommmandLine),
        .init("q", mod: nil, action: .quitApplication),
    ]
}
