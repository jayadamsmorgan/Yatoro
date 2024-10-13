import SwiftNotCurses

public struct Mapping: Codable {

    public var key: String
    public var modifiers: [Input.Modifier]?
    public let action: Action

    public init(_ key: String, mod: [Input.Modifier]?, action: Action) {
        self.key = key
        self.modifiers = mod
        self.action = action
    }

    public enum Action: String, Codable {
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
    @MainActor static let defaultMappings: [Mapping] = [
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
