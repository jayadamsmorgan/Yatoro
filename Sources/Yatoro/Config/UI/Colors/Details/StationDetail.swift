extension Config.UIConfig.Colors {

    public struct StationDetail {
        public var page: ColorPair
        public var border: ColorPair
        public var songIndices: ColorPair
        public var stationTitle: ColorPair
        public var songsText: ColorPair

        public var songItem: SongItem

        public init() {
            self.page = .init()
            self.border = .init()
            self.songIndices = .init()
            self.stationTitle = .init()
            self.songsText = .init()

            self.songItem = .init()
        }
    }
}

extension Config.UIConfig.Colors.StationDetail: Codable {

    enum CodingKeys: String, CodingKey {
        case page
        case border
        case songIndices
        case stationTitle
        case songsText
        case songItem
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.page =
            try container.decodeIfPresent(Config.UIConfig.Colors.ColorPair.self, forKey: .page)
            ?? .init()
        self.border =
            try container.decodeIfPresent(Config.UIConfig.Colors.ColorPair.self, forKey: .border)
            ?? .init()
        self.songIndices =
            try container.decodeIfPresent(Config.UIConfig.Colors.ColorPair.self, forKey: .songIndices)
            ?? .init()
        self.stationTitle =
            try container.decodeIfPresent(Config.UIConfig.Colors.ColorPair.self, forKey: .stationTitle)
            ?? .init()
        self.songsText =
            try container.decodeIfPresent(Config.UIConfig.Colors.ColorPair.self, forKey: .songsText)
            ?? .init()

        self.songItem =
            try container.decodeIfPresent(Config.UIConfig.Colors.SongItem.self, forKey: .songItem)
            ?? .init()
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.page, forKey: .page)
        try container.encode(self.border, forKey: .border)
        try container.encode(self.songIndices, forKey: .songIndices)
        try container.encode(self.stationTitle, forKey: .stationTitle)
        try container.encode(self.songsText, forKey: .songsText)

        try container.encode(self.songItem, forKey: .songItem)
    }

}
