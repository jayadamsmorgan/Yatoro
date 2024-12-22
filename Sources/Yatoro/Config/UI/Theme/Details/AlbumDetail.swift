extension Theme {

    public struct AlbumDetail {
        public var page: ColorPair
        public var border: ColorPair
        public var artistIndices: ColorPair
        public var songIndices: ColorPair
        public var albumTitle: ColorPair
        public var artistsText: ColorPair
        public var songsText: ColorPair

        public var songItem: SongItem
        public var artistItem: ArtistItem

        public init() {
            self.page = .init()
            self.border = .init()
            self.artistIndices = .init()
            self.songIndices = .init()
            self.albumTitle = .init()
            self.artistsText = .init()
            self.songsText = .init()

            self.songItem = .init()
            self.artistItem = .init()
        }
    }
}

extension Theme.AlbumDetail: Codable {

    enum CodingKeys: String, CodingKey {
        case page
        case border
        case artistIndices
        case songIndices
        case albumTitle
        case artistsText
        case songsText
        case songItem
        case artistItem
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.page =
            try container.decodeIfPresent(Theme.ColorPair.self, forKey: .page)
            ?? .init()
        self.border =
            try container.decodeIfPresent(Theme.ColorPair.self, forKey: .border)
            ?? .init()
        self.artistIndices =
            try container.decodeIfPresent(Theme.ColorPair.self, forKey: .artistIndices)
            ?? .init()
        self.songIndices =
            try container.decodeIfPresent(Theme.ColorPair.self, forKey: .songIndices)
            ?? .init()
        self.albumTitle =
            try container.decodeIfPresent(Theme.ColorPair.self, forKey: .albumTitle)
            ?? .init()
        self.artistsText =
            try container.decodeIfPresent(Theme.ColorPair.self, forKey: .artistsText)
            ?? .init()
        self.songsText =
            try container.decodeIfPresent(Theme.ColorPair.self, forKey: .songsText)
            ?? .init()

        self.songItem =
            try container.decodeIfPresent(Theme.SongItem.self, forKey: .songItem)
            ?? .init()
        self.artistItem =
            try container.decodeIfPresent(Theme.ArtistItem.self, forKey: .artistItem)
            ?? .init()
    }

}
