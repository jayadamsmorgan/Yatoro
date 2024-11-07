extension Config.UIConfig.Colors {

    public struct Queue {
        public var page: ColorPair
        public var border: ColorPair
        public var pageName: ColorPair

        public var shuffleMode: ColorPair
        public var repeatMode: ColorPair

        public var songItem: SongItem

        public init() {
            self.page = .init()
            self.border = .init()
            self.pageName = .init()
            self.songItem = .init()
            self.shuffleMode = .init()
            self.repeatMode = .init()
        }
    }
}

extension Config.UIConfig.Colors.Queue: Codable {

    enum CodingKeys: String, CodingKey {
        case page
        case border
        case pageName
        case shuffleMode
        case repeatMode

        case songItem
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.page =
            try container.decodeIfPresent(Config.UIConfig.Colors.ColorPair.self, forKey: .page)
            ?? .init()
        self.pageName =
            try container.decodeIfPresent(Config.UIConfig.Colors.ColorPair.self, forKey: .pageName)
            ?? .init()
        self.border =
            try container.decodeIfPresent(Config.UIConfig.Colors.ColorPair.self, forKey: .border)
            ?? .init()
        self.songItem =
            try container.decodeIfPresent(Config.UIConfig.Colors.SongItem.self, forKey: .songItem)
            ?? .init()
        self.shuffleMode =
            try container.decodeIfPresent(Config.UIConfig.Colors.ColorPair.self, forKey: .shuffleMode)
            ?? .init()
        self.repeatMode =
            try container.decodeIfPresent(Config.UIConfig.Colors.ColorPair.self, forKey: .repeatMode)
            ?? .init()
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.page, forKey: .page)
        try container.encode(self.pageName, forKey: .pageName)
        try container.encode(self.border, forKey: .border)
        try container.encode(self.songItem, forKey: .songItem)
        try container.encode(self.shuffleMode, forKey: .shuffleMode)
        try container.encode(self.repeatMode, forKey: .repeatMode)
    }

}
