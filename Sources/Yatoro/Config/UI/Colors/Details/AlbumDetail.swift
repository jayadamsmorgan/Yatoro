extension Config.UIConfig.Colors {

    public struct AlbumDetail {
        public var page: ColorPair
        public var border: ColorPair
        public var artistIndices: ColorPair
        public var songsIndices: ColorPair
        public var albumTitle: ColorPair
        public var artistsText: ColorPair
        public var songsText: ColorPair

        public var songItem: SongItem
        public var artistItem: ArtistItem

        public init() {
            self.page = .init()
            self.border = .init()
            self.artistIndices = .init()
            self.songsIndices = .init()
            self.albumTitle = .init()
            self.artistsText = .init()
            self.songsText = .init()

            self.songItem = .init()
            self.artistItem = .init()
        }
    }
}

extension Config.UIConfig.Colors.AlbumDetail: Codable {

    enum CodingKeys: String, CodingKey {
        case page
        case border
        case artistIndices
        case songsIndices
        case albumTitle
        case artistsText
        case songsText
        case songItem
        case artistItem
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.page =
            try container.decodeIfPresent(Config.UIConfig.Colors.ColorPair.self, forKey: .page)
            ?? .init()
        self.border =
            try container.decodeIfPresent(Config.UIConfig.Colors.ColorPair.self, forKey: .border)
            ?? .init()
        self.artistIndices =
            try container.decodeIfPresent(Config.UIConfig.Colors.ColorPair.self, forKey: .artistIndices)
            ?? .init()
        self.songsIndices =
            try container.decodeIfPresent(Config.UIConfig.Colors.ColorPair.self, forKey: .songsIndices)
            ?? .init()
        self.albumTitle =
            try container.decodeIfPresent(Config.UIConfig.Colors.ColorPair.self, forKey: .albumTitle)
            ?? .init()
        self.artistsText =
            try container.decodeIfPresent(Config.UIConfig.Colors.ColorPair.self, forKey: .artistsText)
            ?? .init()
        self.songsText =
            try container.decodeIfPresent(Config.UIConfig.Colors.ColorPair.self, forKey: .songsText)
            ?? .init()

        self.songItem =
            try container.decodeIfPresent(Config.UIConfig.Colors.SongItem.self, forKey: .songItem)
            ?? .init()
        self.artistItem =
            try container.decodeIfPresent(Config.UIConfig.Colors.ArtistItem.self, forKey: .artistItem)
            ?? .init()
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.page, forKey: .page)
        try container.encode(self.border, forKey: .border)
        try container.encode(self.artistIndices, forKey: .artistIndices)
        try container.encode(self.songsIndices, forKey: .songsIndices)
        try container.encode(self.albumTitle, forKey: .albumTitle)
        try container.encode(self.artistsText, forKey: .artistsText)
        try container.encode(self.songsText, forKey: .songsText)

        try container.encode(self.songItem, forKey: .songItem)
        try container.encode(self.artistItem, forKey: .artistItem)
    }

}
