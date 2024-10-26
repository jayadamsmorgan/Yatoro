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
        case stopSeeking
        case playPrevious
        case startSeekingBackward
        case restartSong
        case startSearching
        case openCommmandLine
        case stationFromCurrentEntry
        case quitApplication
    }
}

public extension Mapping {
    @MainActor static let defaultMappings: [Mapping] = [
        .init("p", mod: nil, action: .playPauseToggle),
        .init("p", mod: [.alt], action: .play),
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
        .init(":", mod: [.shift], action: .openCommmandLine),
        .init("s", mod: [.ctrl], action: .stationFromCurrentEntry),
        .init("q", mod: nil, action: .quitApplication),
    ]
}
