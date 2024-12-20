extension Theme {

    public struct CommandLine {
        public var page: ColorPair
        public var modeNormal: ColorPair
        public var modeCommand: ColorPair
        public var playStatus: ColorPair
        public var time: ColorPair
        public var input: ColorPair
        public var nowPlayingArtist: ColorPair
        public var nowPlayingDash: ColorPair
        public var nowPlayingTitle: ColorPair
        public var completions: ColorPair
        public var completionSelected: ColorPair

        public init() {
            self.page = .init()
            self.modeNormal = .init()
            self.modeCommand = .init()
            self.playStatus = .init()
            self.time = .init()
            self.input = .init()
            self.nowPlayingArtist = .init()
            self.nowPlayingDash = .init()
            self.nowPlayingTitle = .init()
            self.completions = .init()
            self.completionSelected = .init()
        }
    }

}

extension Theme.CommandLine: Codable {

    enum CodingKeys: String, CodingKey {
        case page
        case modeNormal
        case modeCommand
        case playStatus
        case time
        case input
        case nowPlayingArtist
        case nowPlayingDash
        case nowPlayingTitle
        case completions
        case completionSelected
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.page =
            try container.decodeIfPresent(Theme.ColorPair.self, forKey: .page)
            ?? .init()
        self.modeNormal =
            try container.decodeIfPresent(Theme.ColorPair.self, forKey: .modeNormal)
            ?? .init()
        self.modeCommand =
            try container.decodeIfPresent(Theme.ColorPair.self, forKey: .modeCommand)
            ?? .init()
        self.playStatus =
            try container.decodeIfPresent(Theme.ColorPair.self, forKey: .playStatus)
            ?? .init()
        self.time =
            try container.decodeIfPresent(Theme.ColorPair.self, forKey: .time)
            ?? .init()
        self.input =
            try container.decodeIfPresent(Theme.ColorPair.self, forKey: .input)
            ?? .init()
        self.nowPlayingArtist =
            try container.decodeIfPresent(Theme.ColorPair.self, forKey: .nowPlayingArtist)
            ?? .init()
        self.nowPlayingDash =
            try container.decodeIfPresent(Theme.ColorPair.self, forKey: .nowPlayingDash)
            ?? .init()
        self.nowPlayingTitle =
            try container.decodeIfPresent(Theme.ColorPair.self, forKey: .nowPlayingTitle)
            ?? .init()
        self.completions =
            try container.decodeIfPresent(Theme.ColorPair.self, forKey: .completions)
            ?? .init()
        self.completionSelected =
            try container.decodeIfPresent(Theme.ColorPair.self, forKey: .completionSelected)
            ?? .init()
    }

}
