import SwiftNotCurses

public struct Mapping: Codable {

    public var key: String
    public var modifiers: [Input.Modifier]?
    public let action: String

    public var remap: Bool = false

    public init(_ key: String, mod: [Input.Modifier]?, action: String) {
        self.key = key
        self.modifiers = mod
        self.action = action
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.key = try container.decodeIfPresent(String.self, forKey: .key) ?? ""
        var modifiers: [Input.Modifier] = []
        if let strModifiers = try container.decodeIfPresent(Array<String>.self, forKey: .modifiers) {
            for strModifier in strModifiers {
                if let mod = Input.Modifier(rawValue: strModifier.lowercased()) {
                    modifiers.append(mod)
                }
            }
        }
        if !modifiers.isEmpty {
            self.modifiers = modifiers
        }
        self.action = try container.decodeIfPresent(String.self, forKey: .action) ?? ""
        self.remap = try container.decodeIfPresent(Bool.self, forKey: .remap) ?? false
    }
}

public extension Mapping {
    @MainActor static let defaultMappings: [Mapping] = [
        .init("p", mod: nil, action: ":playPauseToggle<CR>"),
        .init("p", mod: [.shift], action: ":play<CR>"),
        .init("p", mod: [.ctrl], action: ":pause<CR>"),
        .init("c", mod: nil, action: ":stop<CR>"),
        .init("x", mod: nil, action: ":clearQueue<CR>"),
        .init("f", mod: nil, action: ":playNext<CR>"),
        .init("f", mod: [.ctrl], action: ":startSeekingForward<CR>"),
        .init("g", mod: nil, action: ":stopSeeking<CR>"),
        .init("b", mod: nil, action: ":playPrevious<CR>"),
        .init("b", mod: [.ctrl], action: ":startSeekingBackward<CR>"),
        .init("r", mod: nil, action: ":restartSong<CR>"),
        .init("s", mod: nil, action: ":search "),
        .init("s", mod: [.ctrl], action: ":stationFromCurrentEntry<CR>"),
        .init("q", mod: nil, action: ":quitApplication<CR>"),
        .init("e", mod: nil, action: ":repeatMode<CR>"),
        .init("h", mod: nil, action: ":shuffleMode<CR>"),
    ]
}
