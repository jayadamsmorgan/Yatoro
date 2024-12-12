extension Config.UIConfig.Colors {

    public struct ArtistDetail {
        public var page: ColorPair
        public var border: ColorPair
        public var topSongIndices: ColorPair
        public var albumIndices: ColorPair
        public var artistTitle: ColorPair
        public var topSongsText: ColorPair
        public var albumsText: ColorPair

        public var songItem: SongItem
        public var albumItem: AlbumItem

        public init() {
            self.page = .init()
            self.border = .init()
            self.topSongIndices = .init()
            self.albumIndices = .init()
            self.artistTitle = .init()
            self.topSongsText = .init()
            self.albumsText = .init()

            self.songItem = .init()
            self.albumItem = .init()
        }
    }
}

extension Config.UIConfig.Colors.ArtistDetail: Codable {

    enum CodingKeys: String, CodingKey {
        case page
        case border
        case topSongIndices
        case albumIndices
        case artistTitle
        case topSongsText
        case albumsText
        case songItem
        case albumItem
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.page =
            try container.decodeIfPresent(Config.UIConfig.Colors.ColorPair.self, forKey: .page)
            ?? .init()
        self.border =
            try container.decodeIfPresent(Config.UIConfig.Colors.ColorPair.self, forKey: .border)
            ?? .init()
        self.topSongIndices =
            try container.decodeIfPresent(Config.UIConfig.Colors.ColorPair.self, forKey: .topSongIndices)
            ?? .init()
        self.albumIndices =
            try container.decodeIfPresent(Config.UIConfig.Colors.ColorPair.self, forKey: .albumIndices)
            ?? .init()
        self.artistTitle =
            try container.decodeIfPresent(Config.UIConfig.Colors.ColorPair.self, forKey: .artistTitle)
            ?? .init()
        self.topSongsText =
            try container.decodeIfPresent(Config.UIConfig.Colors.ColorPair.self, forKey: .topSongsText)
            ?? .init()
        self.albumsText =
            try container.decodeIfPresent(Config.UIConfig.Colors.ColorPair.self, forKey: .albumsText)
            ?? .init()

        self.songItem =
            try container.decodeIfPresent(Config.UIConfig.Colors.SongItem.self, forKey: .songItem)
            ?? .init()
        self.albumItem =
            try container.decodeIfPresent(Config.UIConfig.Colors.AlbumItem.self, forKey: .albumItem)
            ?? .init()
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.page, forKey: .page)
        try container.encode(self.border, forKey: .border)
        try container.encode(self.topSongIndices, forKey: .topSongIndices)
        try container.encode(self.albumIndices, forKey: .albumIndices)
        try container.encode(self.artistTitle, forKey: .artistTitle)
        try container.encode(self.topSongsText, forKey: .topSongsText)
        try container.encode(self.albumsText, forKey: .albumsText)

        try container.encode(self.songItem, forKey: .songItem)
        try container.encode(self.albumItem, forKey: .albumItem)
    }

}
