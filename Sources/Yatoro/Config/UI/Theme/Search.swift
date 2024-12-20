extension Theme {

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

extension Theme.Search: Codable {

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
            try container.decodeIfPresent(Theme.ColorPair.self, forKey: .page)
            ?? .init()
        self.pageName =
            try container.decodeIfPresent(Theme.ColorPair.self, forKey: .pageName)
            ?? .init()
        self.border =
            try container.decodeIfPresent(Theme.ColorPair.self, forKey: .border)
            ?? .init()
        self.searchPhrase =
            try container.decodeIfPresent(Theme.ColorPair.self, forKey: .searchPhrase)
            ?? .init()
        self.itemIndices =
            try container.decodeIfPresent(Theme.ColorPair.self, forKey: .itemIndices)
            ?? .init()
        self.songItem =
            try container.decodeIfPresent(Theme.SongItem.self, forKey: .songItem)
            ?? .init()
        self.albumItem =
            try container.decodeIfPresent(Theme.AlbumItem.self, forKey: .albumItem)
            ?? .init()
        self.artistItem =
            try container.decodeIfPresent(Theme.ArtistItem.self, forKey: .artistItem)
            ?? .init()
        self.playlistItem =
            try container.decodeIfPresent(Theme.PlaylistItem.self, forKey: .playlistItem)
            ?? .init()
        self.stationItem =
            try container.decodeIfPresent(Theme.StationItem.self, forKey: .stationItem)
            ?? .init()
        self.recommendationItem =
            try container.decodeIfPresent(Theme.RecommendationItem.self, forKey: .recommendationItem)
            ?? .init()
    }

}
