extension Config.UIConfig.Colors {

    public struct Search {
        public var page: ColorPair
        public var border: ColorPair
        public var pageName: ColorPair
        public var searchPhrase: ColorPair
        public var itemIndices: ColorPair

        public var songItem: SongItem
        public var albumItem: AlbumItem
        public var artistItem: ArtistItem
        public var playlistItem: PlaylistItem
        public var stationItem: StationItem
        public var recommendationItem: RecommendationItem

        public init() {
            self.page = .init()
            self.border = .init()
            self.pageName = .init()
            self.searchPhrase = .init()
            self.songItem = .init()
            self.albumItem = .init()
            self.artistItem = .init()
            self.playlistItem = .init()
            self.stationItem = .init()
            self.recommendationItem = .init()
            self.itemIndices = .init()
        }
    }
}

extension Config.UIConfig.Colors.Search: Codable {

    enum CodingKeys: String, CodingKey {
        case page
        case border
        case pageName
        case searchPhrase
        case itemIndices
        case songItem
        case albumItem
        case artistItem
        case playlistItem
        case stationItem
        case recommendationItem
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
        self.searchPhrase =
            try container.decodeIfPresent(Config.UIConfig.Colors.ColorPair.self, forKey: .searchPhrase)
            ?? .init()
        self.itemIndices =
            try container.decodeIfPresent(Config.UIConfig.Colors.ColorPair.self, forKey: .itemIndices)
            ?? .init()
        self.songItem =
            try container.decodeIfPresent(Config.UIConfig.Colors.SongItem.self, forKey: .songItem)
            ?? .init()
        self.albumItem =
            try container.decodeIfPresent(Config.UIConfig.Colors.AlbumItem.self, forKey: .albumItem)
            ?? .init()
        self.artistItem =
            try container.decodeIfPresent(Config.UIConfig.Colors.ArtistItem.self, forKey: .artistItem)
            ?? .init()
        self.playlistItem =
            try container.decodeIfPresent(Config.UIConfig.Colors.PlaylistItem.self, forKey: .playlistItem)
            ?? .init()
        self.stationItem =
            try container.decodeIfPresent(Config.UIConfig.Colors.StationItem.self, forKey: .stationItem)
            ?? .init()
        self.recommendationItem =
            try container.decodeIfPresent(Config.UIConfig.Colors.RecommendationItem.self, forKey: .recommendationItem)
            ?? .init()
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.page, forKey: .page)
        try container.encode(self.pageName, forKey: .pageName)
        try container.encode(self.border, forKey: .border)
        try container.encode(self.searchPhrase, forKey: .searchPhrase)
        try container.encode(self.itemIndices, forKey: .itemIndices)
        try container.encode(self.songItem, forKey: .songItem)
        try container.encode(self.albumItem, forKey: .albumItem)
        try container.encode(self.artistItem, forKey: .artistItem)
        try container.encode(self.playlistItem, forKey: .playlistItem)
        try container.encode(self.stationItem, forKey: .stationItem)
        try container.encode(self.recommendationItem, forKey: .recommendationItem)
    }

}
