extension Theme {

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

extension Theme.ArtistDetail: Codable {

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
            try container.decodeIfPresent(Theme.ColorPair.self, forKey: .page)
            ?? .init()
        self.border =
            try container.decodeIfPresent(Theme.ColorPair.self, forKey: .border)
            ?? .init()
        self.topSongIndices =
            try container.decodeIfPresent(Theme.ColorPair.self, forKey: .topSongIndices)
            ?? .init()
        self.albumIndices =
            try container.decodeIfPresent(Theme.ColorPair.self, forKey: .albumIndices)
            ?? .init()
        self.artistTitle =
            try container.decodeIfPresent(Theme.ColorPair.self, forKey: .artistTitle)
            ?? .init()
        self.topSongsText =
            try container.decodeIfPresent(Theme.ColorPair.self, forKey: .topSongsText)
            ?? .init()
        self.albumsText =
            try container.decodeIfPresent(Theme.ColorPair.self, forKey: .albumsText)
            ?? .init()

        self.songItem =
            try container.decodeIfPresent(Theme.SongItem.self, forKey: .songItem)
            ?? .init()
        self.albumItem =
            try container.decodeIfPresent(Theme.AlbumItem.self, forKey: .albumItem)
            ?? .init()
    }

}
