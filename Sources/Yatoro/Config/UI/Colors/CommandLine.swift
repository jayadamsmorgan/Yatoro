extension Config.UIConfig.Colors {

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

extension Config.UIConfig.Colors.CommandLine: Codable {

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
            try container.decodeIfPresent(Config.UIConfig.Colors.ColorPair.self, forKey: .page)
            ?? .init()
        self.modeNormal =
            try container.decodeIfPresent(Config.UIConfig.Colors.ColorPair.self, forKey: .modeNormal)
            ?? .init()
        self.modeCommand =
            try container.decodeIfPresent(Config.UIConfig.Colors.ColorPair.self, forKey: .modeCommand)
            ?? .init()
        self.playStatus =
            try container.decodeIfPresent(Config.UIConfig.Colors.ColorPair.self, forKey: .playStatus)
            ?? .init()
        self.time =
            try container.decodeIfPresent(Config.UIConfig.Colors.ColorPair.self, forKey: .time)
            ?? .init()
        self.input =
            try container.decodeIfPresent(Config.UIConfig.Colors.ColorPair.self, forKey: .input)
            ?? .init()
        self.nowPlayingArtist =
            try container.decodeIfPresent(Config.UIConfig.Colors.ColorPair.self, forKey: .nowPlayingArtist)
            ?? .init()
        self.nowPlayingDash =
            try container.decodeIfPresent(Config.UIConfig.Colors.ColorPair.self, forKey: .nowPlayingDash)
            ?? .init()
        self.nowPlayingTitle =
            try container.decodeIfPresent(Config.UIConfig.Colors.ColorPair.self, forKey: .nowPlayingTitle)
            ?? .init()
        self.completions =
            try container.decodeIfPresent(Config.UIConfig.Colors.ColorPair.self, forKey: .completions)
            ?? .init()
        self.completionSelected =
            try container.decodeIfPresent(Config.UIConfig.Colors.ColorPair.self, forKey: .completionSelected)
            ?? .init()
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.page, forKey: .page)
        try container.encode(self.modeNormal, forKey: .modeNormal)
        try container.encode(self.modeCommand, forKey: .modeCommand)
        try container.encode(self.playStatus, forKey: .playStatus)
        try container.encode(self.time, forKey: .time)
        try container.encode(self.input, forKey: .input)
        try container.encode(self.nowPlayingArtist, forKey: .nowPlayingArtist)
        try container.encode(self.nowPlayingDash, forKey: .nowPlayingDash)
        try container.encode(self.nowPlayingTitle, forKey: .nowPlayingTitle)
        try container.encode(self.completions, forKey: .completions)
        try container.encode(self.completionSelected, forKey: .completionSelected)
    }

}
