extension Config.UIConfig.Colors {

    public struct SongDetail {
        public var page: ColorPair
        public var border: ColorPair
        public var artistIndices: ColorPair
        public var albumIndex: ColorPair
        public var songTitle: ColorPair
        public var artistsText: ColorPair
        public var albumText: ColorPair

        public var albumItem: AlbumItem
        public var artistItem: ArtistItem

        public init() {
            self.page = .init()
            self.border = .init()
            self.artistIndices = .init()
            self.albumIndex = .init()
            self.songTitle = .init()
            self.artistsText = .init()
            self.albumText = .init()

            self.albumItem = .init()
            self.artistItem = .init()
        }
    }
}

extension Config.UIConfig.Colors.SongDetail: Codable {

    enum CodingKeys: String, CodingKey {
        case page
        case border
        case artistIndices
        case albumIndex
        case songTitle
        case artistsText
        case albumText
        case albumItem
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
        self.albumIndex =
            try container.decodeIfPresent(Config.UIConfig.Colors.ColorPair.self, forKey: .albumIndex)
            ?? .init()
        self.songTitle =
            try container.decodeIfPresent(Config.UIConfig.Colors.ColorPair.self, forKey: .songTitle)
            ?? .init()
        self.artistsText =
            try container.decodeIfPresent(Config.UIConfig.Colors.ColorPair.self, forKey: .artistsText)
            ?? .init()
        self.albumText =
            try container.decodeIfPresent(Config.UIConfig.Colors.ColorPair.self, forKey: .albumText)
            ?? .init()

        self.albumItem =
            try container.decodeIfPresent(Config.UIConfig.Colors.AlbumItem.self, forKey: .albumItem)
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
        try container.encode(self.albumIndex, forKey: .albumIndex)
        try container.encode(self.songTitle, forKey: .songTitle)
        try container.encode(self.artistsText, forKey: .artistsText)
        try container.encode(self.albumText, forKey: .albumText)

        try container.encode(self.albumItem, forKey: .albumItem)
        try container.encode(self.artistItem, forKey: .artistItem)
    }

}
