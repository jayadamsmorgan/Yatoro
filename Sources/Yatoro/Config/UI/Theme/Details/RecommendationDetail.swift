extension Theme {

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

extension Theme.RecommendationDetail: Codable {

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
            try container.decodeIfPresent(Theme.ColorPair.self, forKey: .page)
            ?? .init()
        self.border =
            try container.decodeIfPresent(Theme.ColorPair.self, forKey: .border)
            ?? .init()

        self.recommendationTitle =
            try container.decodeIfPresent(Theme.ColorPair.self, forKey: .recommendationTitle)
            ?? .init()

        self.albumsText =
            try container.decodeIfPresent(Theme.ColorPair.self, forKey: .albumsText)
            ?? .init()
        self.albumIndices =
            try container.decodeIfPresent(Theme.ColorPair.self, forKey: .albumIndices)
            ?? .init()
        self.stationsText =
            try container.decodeIfPresent(Theme.ColorPair.self, forKey: .stationsText)
            ?? .init()
        self.stationIndices =
            try container.decodeIfPresent(Theme.ColorPair.self, forKey: .stationIndices)
            ?? .init()
        self.playlistsText =
            try container.decodeIfPresent(Theme.ColorPair.self, forKey: .playlistsText)
            ?? .init()
        self.playlistIndices =
            try container.decodeIfPresent(Theme.ColorPair.self, forKey: .playlistIndices)
            ?? .init()

        self.albumItem =
            try container.decodeIfPresent(Theme.AlbumItem.self, forKey: .albumItem)
            ?? .init()
        self.stationItem =
            try container.decodeIfPresent(Theme.StationItem.self, forKey: .stationItem)
            ?? .init()
        self.playlistItem =
            try container.decodeIfPresent(Theme.PlaylistItem.self, forKey: .playlistItem)
            ?? .init()
    }

}
