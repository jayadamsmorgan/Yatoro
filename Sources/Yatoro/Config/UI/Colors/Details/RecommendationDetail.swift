extension Config.UIConfig.Colors {

    public struct RecommendationDetail {
        public var page: ColorPair
        public var border: ColorPair

        public var recommendationTitle: ColorPair

        public var albumsText: ColorPair
        public var albumIndices: ColorPair
        public var stationsText: ColorPair
        public var stationIndices: ColorPair
        public var playlistsText: ColorPair
        public var playlistIndices: ColorPair

        public var albumItem: AlbumItem
        public var stationItem: StationItem
        public var playlistItem: PlaylistItem

        public init() {
            self.page = .init()
            self.border = .init()

            self.recommendationTitle = .init()

            self.albumsText = .init()
            self.albumIndices = .init()
            self.stationsText = .init()
            self.stationIndices = .init()
            self.playlistsText = .init()
            self.playlistIndices = .init()

            self.albumItem = .init()
            self.stationItem = .init()
            self.playlistItem = .init()
        }
    }
}

extension Config.UIConfig.Colors.RecommendationDetail: Codable {

    enum CodingKeys: String, CodingKey {
        case page
        case border

        case recommendationTitle

        case albumsText
        case albumIndices
        case stationsText
        case stationIndices
        case playlistsText
        case playlistIndices

        case albumItem
        case stationItem
        case playlistItem
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.page =
            try container.decodeIfPresent(Config.UIConfig.Colors.ColorPair.self, forKey: .page)
            ?? .init()
        self.border =
            try container.decodeIfPresent(Config.UIConfig.Colors.ColorPair.self, forKey: .border)
            ?? .init()

        self.recommendationTitle =
            try container.decodeIfPresent(Config.UIConfig.Colors.ColorPair.self, forKey: .recommendationTitle)
            ?? .init()

        self.albumsText =
            try container.decodeIfPresent(Config.UIConfig.Colors.ColorPair.self, forKey: .albumsText)
            ?? .init()
        self.albumIndices =
            try container.decodeIfPresent(Config.UIConfig.Colors.ColorPair.self, forKey: .albumIndices)
            ?? .init()
        self.stationsText =
            try container.decodeIfPresent(Config.UIConfig.Colors.ColorPair.self, forKey: .stationsText)
            ?? .init()
        self.stationIndices =
            try container.decodeIfPresent(Config.UIConfig.Colors.ColorPair.self, forKey: .stationIndices)
            ?? .init()
        self.playlistsText =
            try container.decodeIfPresent(Config.UIConfig.Colors.ColorPair.self, forKey: .playlistsText)
            ?? .init()
        self.playlistIndices =
            try container.decodeIfPresent(Config.UIConfig.Colors.ColorPair.self, forKey: .playlistIndices)
            ?? .init()

        self.albumItem =
            try container.decodeIfPresent(Config.UIConfig.Colors.AlbumItem.self, forKey: .albumItem)
            ?? .init()
        self.stationItem =
            try container.decodeIfPresent(Config.UIConfig.Colors.StationItem.self, forKey: .stationItem)
            ?? .init()
        self.playlistItem =
            try container.decodeIfPresent(Config.UIConfig.Colors.PlaylistItem.self, forKey: .playlistItem)
            ?? .init()
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.page, forKey: .page)
        try container.encode(self.border, forKey: .border)

        try container.encode(self.recommendationTitle, forKey: .recommendationTitle)

        try container.encode(self.albumsText, forKey: .albumsText)
        try container.encode(self.albumIndices, forKey: .albumIndices)
        try container.encode(self.stationsText, forKey: .stationsText)
        try container.encode(self.stationIndices, forKey: .stationIndices)
        try container.encode(self.playlistsText, forKey: .playlistsText)
        try container.encode(self.playlistIndices, forKey: .playlistIndices)

        try container.encode(self.albumItem, forKey: .albumItem)
        try container.encode(self.stationItem, forKey: .stationItem)
        try container.encode(self.playlistItem, forKey: .playlistItem)
    }

}
